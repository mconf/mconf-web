/*
 * Copyright (C) 2003-2007 
 * Nick Velloff <nick.velloff@gmail.com>
 * Derrick Grigg <dgrigg@rogers.com>
 * Sean Voisen <sean@voisen.org>
 * Sean Treadway <seant@oncotype.dk>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
 *
 */
	 
package org.jivesoftware.xiff.core
{	 
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.XMLSocket;
	import flash.utils.Timer;
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;
	
	import mx.logging.ILogger;
	
	import org.jivesoftware.xiff.auth.Anonymous;
	import org.jivesoftware.xiff.auth.External;
	import org.jivesoftware.xiff.auth.Plain;
	import org.jivesoftware.xiff.auth.SASLAuth;
	import org.jivesoftware.xiff.data.Extension;
	import org.jivesoftware.xiff.data.IExtension;
	import org.jivesoftware.xiff.data.IQ;
	import org.jivesoftware.xiff.data.Message;
	import org.jivesoftware.xiff.data.Presence;
	import org.jivesoftware.xiff.data.XMPPStanza;
	import org.jivesoftware.xiff.data.auth.AuthExtension;
	import org.jivesoftware.xiff.data.bind.BindExtension;
	import org.jivesoftware.xiff.data.forms.FormExtension;
	import org.jivesoftware.xiff.data.register.RegisterExtension;
	import org.jivesoftware.xiff.data.session.SessionExtension;
	import org.jivesoftware.xiff.events.*;
	import org.jivesoftware.xiff.exception.SerializationException;
	import org.jivesoftware.xiff.logging.LoggerFactory;

	/**
	 * Dispatched when a password change is successful.
	 * 
	 * @eventType org.jivesoftware.xiff.events.ChangePasswordSuccessEvent.PASSWORD_SUCCESS
	 */
    [Event(name="changePasswordSuccess", type="org.jivesoftware.xiff.events.ChangePasswordSuccessEvent")]
    
    /**
     * Dispatched when the connection is successfully made to the server.
     * 
     * @eventType org.jivesoftware.xiff.events.ConnectionSuccessEvent.CONNECT_SUCCESS
     */
    [Event(name="connection", type="org.jivesoftware.xiff.events.ConnectionSuccessEvent")]
    
    /**
     * Dispatched when there is a disconnection from the server.
     * 
     * @eventType org.jivesoftware.xiff.events.DisconnectionEvent.DISCONNECT
     */
    [Event(name="disconnection", type="org.jivesoftware.xiff.events.DisconnectionEvent")]
    
    /**
     * Dispatched when there is some type of XMPP error.
     * 
     * @eventType org.jivesoftware.xiff.events.XIFFErrorEvent.XIFF_ERROR
     */
    [Event(name="error", type="org.jivesoftware.xiff.events.XIFFErrorEvent")]
    
    /**
     * Dispatched whenever there is incoming XML data.
     * 
     * @eventType org.jivesoftware.xiff.events.IncomingDataEvent.INCOMING_DATA
     */
    [Event(name="incomingData", type="org.jivesoftware.xiff.events.IncomingDataEvent")]
    
    /**
     * Dispatched on successful authentication (login) with the server.
     * 
     * @eventType org.jivesoftware.xiff.events.LoginEvent.LOGIN
     */
    [Event(name="login", type="org.jivesoftware.xiff.events.LoginEvent")]
    
    /**
     * Dispatched on incoming messages.
     * 
     * @eventType org.jivesoftware.xiff.events.MessageEvent.MESSAGE
     */
    [Event(name="message", type="org.jivesoftware.xiff.events.MessageEvent")]
    
    /**
     * Dispatched whenever data is sent to the server.
     * 
     * @eventType org.jivesoftware.xiff.events.OutgoingDataEvent.OUTGOING_DATA
     */
    [Event(name="outgoingData", type="org.jivesoftware.xiff.events.OutgoingDataEvent")]
    
    /**
     * Dispatched on incoming presence data.
     * 
     * @eventType org.jivesoftware.xiff.events.PresenceEvent.PRESENCE
     */
    [Event(name="presence", type="org.jivesoftware.xiff.events.PresenceEvent")]
    
    /**
     * Dispatched on when new user account registration is successful.
     * 
     * @eventType org.jivesoftware.xiff.events.RegistrationSuccessEvent.REGISTRATION_SUCCESS
     */
    [Event(name="registrationSuccess", type="org.jivesoftware.xiff.events.RegistrationSuccessEvent")]
    
    /**
     * This class is used to connect to and manage data coming from an XMPP server. Use one instance
     * of this class per connection.
     */ 
	public class XMPPConnection extends EventDispatcher
	{
		private static const logger:ILogger = LoggerFactory.getLogger("org.jivesoftware.xiff.core.XMPPConnection");
		
		/**
		 * @private
		 */
		protected var _useAnonymousLogin:Boolean;
		
		/**
		 * @private
		 */
		protected var _socket:XMLSocket;
		
		/**
		 * @private
		 */
		protected var myServer:String;
		
		/**
		 * @private
		 */
	 	protected var myDomain:String;
		
		/**
		 * @private
		 */
		protected var myUsername:String;
		
		/**
		 * @private
		 */
		protected var myResource:String;
		
		/**
		 * @private
		 */
		protected var myPassword:String;
	
		/**
		 * @private
		 */
		protected var myPort:Number;
		
		/**
		 * @private
		 */
		protected var _active:Boolean;
		
		/**
		 * @private
		 */
		protected var loggedIn:Boolean;
		
		/**
		 * @private
		 */
		protected var ignoreWhitespace:Boolean;
		
		/**
		 * @private
		 */
		protected var openingStreamTag:String;
		
		/**
		 * @private
		 */
		protected var closingStreamTag:String;

		/**
		 * @private
		 */
		protected var sessionID:String;
		
		/**
		 * @private
		 */
		protected var pendingIQs:Object;
		
		/**
		 * @private
		 */
		protected var _expireTagSearch:Boolean;
		
		/**
		 * @private
		 */
		protected var auth:SASLAuth;
		
		protected static var _openConnections:Array = [];
		
		protected static var saslMechanisms:Object = {
			"PLAIN":Plain,
			"ANONYMOUS":Anonymous,
            "EXTERNAL":External
		};
		
		public function XMPPConnection()
		{	
			
			// Hash to hold callbacks for IQs
			pendingIQs = new Object();
			
			_useAnonymousLogin = false;
			active = false;
			loggedIn = false;
			ignoreWhitespace = true;
			resource = "xiff";
			port = 5222;
			
			AuthExtension.enable();
			BindExtension.enable();
			SessionExtension.enable();
			RegisterExtension.enable();
			FormExtension.enable();
		}
		
		/**
		 * Connects to the server.
		 *
		 * @param streamType (Optional) The type of initial stream negotiation, either &lt;flash:stream&gt; or &lt;stream:stream&gt;. 
		 * Some servers, like Jabber, Inc.'s XCP and Jabberd 1.4 expect &lt;flash:stream&gt; from a Flash client instead of the standard &lt;stream:stream&gt;.
		 * The options for this parameter are: "flash", "terminatedFlash", "standard" and "terminatedStandard". The default is "terminatedStandard".
		 *
		 * @return A boolean indicating whether the server was found.
		 */
		public function connect( streamType:String = "terminatedStandard" ):Boolean
		{
			
			// Create the socket
			_socket = _createXmlSocket(); 
			
			active = false;
			loggedIn = false;
			
			// Stream type lets user set opening/closing tag - some servers (jadc2s) prefer <stream:flash> to the standard
			// <stream:stream>
			switch( streamType ) {
				case "flash":
					openingStreamTag = new String( "<?xml version=\"1.0\"?><flash:stream to=\"" + domain + "\" xmlns=\"jabber:client\" xmlns:flash=\"http://www.jabber.com/streams/flash\" version=\"1.0\">" );
					closingStreamTag = new String( "</flash:stream>" );
					break;
					
				case "terminatedFlash":
					openingStreamTag = new String( "<?xml version=\"1.0\"?><flash:stream to=\"" + domain + "\" xmlns=\"jabber:client\" xmlns:flash=\"http://www.jabber.com/streams/flash\" version=\"1.0\" />" );
					closingStreamTag = new String( "</flash:stream>" );
					break;
					
				case "standard":
					openingStreamTag = new String( "<?xml version=\"1.0\"?><stream:stream to=\"" + domain + "\" xmlns=\"jabber:client\" xmlns:stream=\"http://etherx.jabber.org/streams\" version=\"1.0\">" );
					closingStreamTag = new String( "</stream:stream>" );
					break;
			
				case "terminatedStandard":
				default:
					openingStreamTag = new String( "<?xml version=\"1.0\"?><stream:stream to=\"" + domain + "\" xmlns=\"jabber:client\" xmlns:stream=\"http://etherx.jabber.org/streams\" version=\"1.0\" />" );
					closingStreamTag = new String( "</stream:stream>" );
					break;
			}
			_socket.connect( server, port );
			return true;
		}
		
		public static function registerSASLMechanism(name:String, authClass:Class):void
		{
			saslMechanisms[name] = authClass;
		}
		
		public static function disableSASLMechanism(name:String):void
		{
			saslMechanisms[name] = null;
		}
		
		/**
		 * Disconnects from the server if currently connected. After disconnect, 
		 * a <code>DisconnectionEvent.DISCONNECT</code> event is broadcast.
		 */
		public function disconnect():void
		{
			if( isActive() ) {
				sendXML( closingStreamTag );
				if(_socket)
					_socket.close();
				active = false;
				loggedIn = false;
				var event:DisconnectionEvent = new DisconnectionEvent();
				dispatchEvent(event);
			}
		}
		
		/**
		 * Sends data to the server. If the data to send cannot be serialized properly, this method throws a <code>SerializeException</code>.
		 *
		 * @param o The data to send. This must be an instance of a class that implements the ISerializable interface.
		 * @see org.jivesoftware.xiff.data.ISerializable
		 * @example The following example sends a basic chat message to the user with the JID "sideshowbob@springfieldpenitentiary.gov".<br />
		 * <pre>var msg:Message = new Message( "sideshowbob@springfieldpenitentiary.gov", null, "Hi Bob.", "<b>Hi Bob.</b>", Message.CHAT_TYPE );
		 * myXMPPConnection.send( msg );</pre>
		 */
		public function send( o:XMPPStanza ):void
		{
			if( isActive() ) {
				if( o is IQ ) {
	                var iq:IQ = o as IQ;
	                if ((iq.callbackName != null && iq.callbackScope != null) || iq.callback != null)
	                {
	                	addIQCallbackToPending( iq.id, iq.callbackName, iq.callbackScope, iq.callback );
	                }		
				}
				var root:XMLNode = o.getNode().parentNode;
				if (root == null) {
					root = new XMLDocument();
				}
	
				if (o.serialize(root)) {
					sendXML( root.firstChild );
				} else {
					throw new SerializationException();
				}
			}
		}
		
		public function sendKeepAlive():void
		{
			if( isActive() ) {
				sendXML(" ");
			}
		}
		
		/**
		 * Determines whether the connection with the server is currently active. (Not necessarily logged in.
		 * For login status, use the <code>isLoggedIn()</code> method.)
		 * 
		 * @return A boolean indicating whether the connection is active.
		 * @see org.jivesoftware.xiff.core.XMPPConnection#isLoggedIn
		 */
		public function isActive():Boolean
		{
			return active;
		}
		
		/**
		 * Determines whether the user is connected and logged into the server.
		 * 
		 * @return A boolean indicating whether the user is logged in.
		 * @see org.jivesoftware.xiff.core.XMPPConnection#isActive
		 */
		public function isLoggedIn():Boolean
		{
			return loggedIn;
		}
		
		/**
		 * Issues a request for the information that must be submitted for registration with the server.
		 * When the data returns, a <code>RegistrationFieldsEvent.REG_FIELDS</code> event is dispatched 
		 * containing the requested data.
		 */
		public function getRegistrationFields():void
		{
			var regIQ:IQ = new IQ( new EscapedJID(domain), IQ.GET_TYPE, XMPPStanza.generateID("reg_info_"), "getRegistrationFields_result", this, null);
			regIQ.addExtension(new RegisterExtension(regIQ.getNode()));
	
			send( regIQ );
		}
		
		/**
		 * Registers a new account with the server, sending the registration data as specified in the fieldMap paramter.
		 *
		 * @param fieldMap An object map containing the data to use for registration. The map should be composed of 
		 * attribute:value pairs for each registration data item.
		 * @param key (Optional) If a key was passed in the "data" field of the "registrationFields" event, 
		 * that key must also be passed here.
		 * required field needed for registration.
		 */
		public function sendRegistrationFields( fieldMap:Object, key:String ):void
		{
			var regIQ:IQ = new IQ( new EscapedJID(domain), IQ.SET_TYPE, XMPPStanza.generateID("reg_attempt_"), "sendRegistrationFields_result", this, null );
			var ext:RegisterExtension = new RegisterExtension(regIQ.getNode());
	
			for( var i:String in fieldMap ) {
				ext[i] = fieldMap[i];
			}
			if (key != null) {
				ext.key = key;
			}
	
			regIQ.addExtension(ext);
			send( regIQ );
		}
		
		/**
		 * Changes the user's account password on the server. If the password change is successful, 
		 * the class will broadcast a <code>ChangePasswordSuccessEvent.PASSWORD_SUCCESS</code> event.
		 *
		 * @param newPassword The new password
		 */
		public function changePassword( newPassword:String ):void
		{
			var passwdIQ:IQ = new IQ( new EscapedJID(domain), IQ.SET_TYPE, XMPPStanza.generateID("pswd_change_"), "changePassword_result", this, null );
			var ext:RegisterExtension = new RegisterExtension(passwdIQ.getNode());
	
			ext.username = jid.escaped.bareJID;
			ext.password = newPassword;
	
			passwdIQ.addExtension(ext);
			send( passwdIQ );
		}
		
		/**
		 * Gets the fully qualified JID (user@server/resource) of the user. A fully-qualified JID includes 
		 * the resource. A bare JID does not. To get the bare JID, use the <code>getBareJID()</code> method.
		 *
		 * @return The fully qualified JID
		 * @see #getBareJID
		 */
		public function get jid():UnescapedJID
		{
			return new UnescapedJID(myUsername + "@" + myDomain + "/" + myResource);
		}
		
		/**
		 * @private
		 */
		protected function changePassword_result( resultIQ:IQ ):void
		{
			if( resultIQ.type == IQ.RESULT_TYPE ) {
				var event:ChangePasswordSuccessEvent = new ChangePasswordSuccessEvent();
				dispatchEvent(event);
			}
			else {
				// We weren't expecting this
				dispatchError( "unexpected-request", "Unexpected Request", "wait", 400 );
			}
		}
		
		/**
		 * @private
		 */
		protected function getRegistrationFields_result( resultIQ:IQ ):void
		{
			try
			{
				var ext:RegisterExtension = resultIQ.getAllExtensionsByNS(RegisterExtension.NS)[0];
				var fields:Array = ext.getRequiredFieldNames(); //TODO, phase this out
				
				var event:RegistrationFieldsEvent = new RegistrationFieldsEvent();
				event.fields = fields;
				event.data = ext;
			}
			catch (e:Error)
			 {
			 	trace(e.getStackTrace());
			 }
		}
		
		/**
		 * @private
		 */
		protected function sendRegistrationFields_result( resultIQ:IQ ):void
		{
			if( resultIQ.type == IQ.RESULT_TYPE ) {

				var event:RegistrationSuccessEvent = new RegistrationSuccessEvent();
				dispatchEvent( event );
			}
			else {
				// We weren't expecting this
				dispatchError( "unexpected-request", "Unexpected Request", "wait", 400 );
			}
		}
		
		// Listener function from the ListenerXMLSocket
		/**
		 * @private
		 */
		protected function socketConnected(ev:Event):void
		{
			active = true;
			sendXML( openingStreamTag );
			var event:ConnectionSuccessEvent = new ConnectionSuccessEvent();
			dispatchEvent( event );
		}
		
		/**
		 * @private
		 */
		protected function socketReceivedData( ev:DataEvent ):void
		{
			// parseXML is more strict in AS3 so we must check for the presence of flash:stream
			// the unterminated tag should be in the first string of xml data retured from the server
			if (!_expireTagSearch) 
			{
				var pattern:RegExp = new RegExp("<flash:stream");
				var resultObj:Object = pattern.exec(ev.data);
				if (resultObj != null) // stop searching for unterminated node
				{
					ev.data = ev.data.concat("</flash:stream>");
					_expireTagSearch = true;
				}
			}
			
			if(ev.data == "</flash:stream>")
			{
				socketClosed(null);
				return;	
			}	
			
			var xmlData:XMLDocument = new XMLDocument();
			xmlData.ignoreWhite = this.ignoreWhite;
			xmlData.parseXML( ev.data );
			
			var event:IncomingDataEvent = new IncomingDataEvent();
			event.data = xmlData;
			dispatchEvent( event );
			
			// Read the data and send it to the appropriate parser
			var firstNode:XMLNode = xmlData.firstChild;
			var nodeName:String = firstNode.nodeName.toLowerCase();
			
			logger.info("INCOMING: {0}", firstNode);
			
			switch( nodeName )
			{
				case "stream:stream":
				case "flash:stream":
					_expireTagSearch = false;
					handleStream( firstNode );
					break;
					
				case "stream:error":
					handleStreamError( firstNode );
					break;
					
				case "iq":
					handleIQ( firstNode );
					break;
					
				case "message":
					handleMessage( firstNode );
					break;
					
				case "presence":
					handlePresence( firstNode );
					break;
					
				case "stream:features":
					handleStreamFeatures( firstNode );
					break;
					
				case "success":
					handleAuthentication( firstNode );
					break;

				case "failure":
					handleAuthentication( firstNode );
					break;
					
				default:
					// silently ignore lack of or unknown stanzas
					// if the app designer wishes to handle raw data they
					// can on "incomingData".
	
					// Use case: received null byte, XMLSocket parses empty document
					// sends empty document
					
					// I am enabling this for debugging
					dispatchError( "undefined-condition", "Unknown Error", "modify", 500 );
					break;
			}
		}
		
		/**
		 * @private
		 */
		protected function socketClosed(e:Event):void
		{	
			var event:DisconnectionEvent = new DisconnectionEvent();
			dispatchEvent( event );
		}
		
		/**
		 * @private
		 */
		protected function handleStream( node:XMLNode ):void
		{
			sessionID = node.attributes.id;
			domain = node.attributes.from;
			
			for each(var childNode:XMLNode in node.childNodes)
			{
				if(childNode.nodeName == "stream:features")
				{
					handleStreamFeatures(childNode);
				}
			}
		}
		
		/**
		 * @private
		 */
		protected function handleStreamFeatures( node:XMLNode ):void
		{
			if(!loggedIn)
			{
				for each(var feature:XMLNode in node.childNodes)
				{
					if (feature.nodeName == "starttls")
					{
						if (feature.firstChild && feature.firstChild.nodeName == "required")
						{
							// No TLS support yet
							dispatchError("TLS required", "The server requires TLS, but this feature is not implemented.", "cancel", 501);
							disconnect();
							return;
						}
					}
					else if (feature.nodeName == "mechanisms")
					{
						configureAuthMechanisms(feature);
					}
					
		        }
		        
				if(useAnonymousLogin || (username != null && username.length > 0))
				{
					beginAuthentication();
				}
				else
				{
					getRegistrationFields();
				}
			}
			else
			{
				bindConnection();
			}
		}
	    
	    /**
		 * @private
		 */
	    protected function configureAuthMechanisms(mechanisms:XMLNode):void
	    {
	        var authMechanism:SASLAuth;
	        var authClass:Class;
	        for each(var mechanism:XMLNode in mechanisms.childNodes) 
	        {
	        	authClass = saslMechanisms[mechanism.firstChild.nodeValue];
	   			if(useAnonymousLogin)
	   			{
	   				if(authClass == Anonymous)
	   					break;
	   			}
	   			else
	   			{
	   				if(authClass) break;
	   			}	   			
	        }
	
	        if (!authClass) {
	        	dispatchError("SASL missing", "The server is not configured to support any available SASL mechanisms", "SASL", -1);
	        	return;
	        }
	        
	        auth = new authClass(this);
	    }
		
		/**
		 * @private
		 */
		protected function handleStreamError( node:XMLNode ):void
		{
			dispatchError( "service-unavailable", "Remote Server Error", "cancel", 502 );
			
			// Cancel everything by closing connection
			try {
				_socket.close();
			}
			catch (error:Error){
				
			}
			active = false;
			loggedIn = false;
			var event:DisconnectionEvent = new DisconnectionEvent();
			
			dispatchEvent( event );
		}
		
		protected function set active(flag:Boolean):void
		{
			if(flag)
			{
				_openConnections.push(this);
			}
			else
			{
				_openConnections.splice(_openConnections.indexOf(this), 1);
			}
			_active = flag;
		}
		
		protected function get active():Boolean
		{
			return _active;
		}
		
		public static function get openConnections():Array
		{
			return _openConnections;
		}
		
		/**
		 * @private
		 */
		protected function handleIQ( node:XMLNode ):IQ
		{
			var iq:IQ = new IQ();
			// Populate the IQ with the incoming data
			if( !iq.deserialize( node ) ) {
				throw new SerializationException();
			}
			
			// If it's an error, handle it
			
			if( iq.type == IQ.ERROR_TYPE) {
				dispatchError( iq.errorCondition, iq.errorMessage, iq.errorType, iq.errorCode );
			}
			else {
				
				// Start the callback for this IQ if one exists
				if( pendingIQs[iq.id] !== undefined ) {
					var callbackInfo:* = pendingIQs[iq.id];
					
					if(callbackInfo.methodScope && callbackInfo.methodName) {
						callbackInfo.methodScope[callbackInfo.methodName].apply( callbackInfo.methodScope, [iq] );
					}			
					if (callbackInfo.func != null) { 
						callbackInfo.func( iq );
					}
					pendingIQs[iq.id] = null;
					delete pendingIQs[iq.id];
				}
				else {
					var exts:Array = iq.getAllExtensions();
					for (var ns:String in exts) {
						// Static type casting
						var ext:IExtension = exts[ns] as IExtension;
						if (ext != null) {
							var event:IQEvent = new IQEvent(ext.getNS());
							event.data = ext;
							event.iq = iq;
							dispatchEvent( event );
						}
					}
				}
			}
	        return iq;
		}
		
		/**
		 * @private
		 */
		protected function handleMessage( node:XMLNode ):Message
		{
			var msg:Message = new Message();
			logger.debug("MESSAGE: {0}", msg);	
			// Populate with data
			if( !msg.deserialize( node ) ) {
				throw new SerializationException();
			}
			// ADDED in error handling for messages
			if( msg.type == Message.ERROR_TYPE ) {
				var exts:Array = msg.getAllExtensions();
				dispatchError( msg.errorCondition, msg.errorMessage, msg.errorType, msg.errorCode, exts.length > 0 ? exts[0] : null);
			}
			else
			{
				var event:MessageEvent = new MessageEvent();
				event.data = msg;
				dispatchEvent( event );		
			}
	        return msg;
		}
		
		/**
		 * @private
		 */
		private var presenceQueue:Array = [];
		private var presenceQueueTimer:Timer;
		protected function handlePresence( node:XMLNode ):Presence
		{
			if(!presenceQueueTimer)
			{
				presenceQueueTimer = new Timer(1, 1);
				presenceQueueTimer.addEventListener(TimerEvent.TIMER_COMPLETE, flushPresenceQueue);
			}
			
			var pres:Presence = new Presence();
			
			// Populate
			if( !pres.deserialize( node ) ) {
				throw new SerializationException();
			}
			
			presenceQueue.push(pres);
			
			presenceQueueTimer.reset();
			presenceQueueTimer.start();

	        return pres;
		}
		
		protected function flushPresenceQueue(evt:TimerEvent):void
		{
			var event:PresenceEvent = new PresenceEvent();
			event.data = presenceQueue;
			dispatchEvent( event );
			presenceQueue = [];
		}
		
		/**
		 * @private
		 */
		protected function onIOError(event:IOErrorEvent):void{
			/*
			this fires the standard dispatchError method. need to add
			the appropriate error code
			*/
			dispatchError( "service-unavailable", "Service Unavailable", "cancel", 503 );
		}
		
		/**
		 * @private
		 */
		protected function securityError(event:SecurityErrorEvent):void{
			trace("there was a security error of type: " + event.type + "\nError: " + event.text);
			dispatchError( "not-authorized", "Not Authorized", "auth", 401 );
		}
		
		/**
		 * @private
		 */
		protected function dispatchError( condition:String, message:String, type:String, code:Number, extension:Extension = null ):void
		{
			logger.error("Error: {0} - {1}", condition, message);
			var event:XIFFErrorEvent = new XIFFErrorEvent();
			event.errorCondition = condition;
			event.errorMessage = message;
			event.errorType = type;
			event.errorCode = code;
			event.errorExt = extension;
			dispatchEvent( event );
		}
		
		/**
		 * @private
		 */
		protected function sendXML( someData:* ):void
		{
			logger.info("OUTGOING: {0}", someData);
			// Data is untyped because it could be a string or XML
			_socket.send( someData );
			var event:OutgoingDataEvent = new OutgoingDataEvent();
			event.data = someData;
			dispatchEvent( event );
		}
		
		/**
		 * @private
		 */
		protected function beginAuthentication():void
		{
	        sendXML(auth.request);
		}
	    
		/**
		 * @private
		 */
	    protected function handleAuthentication(responseBody:XMLNode):void
	    {
	        var status:Object = auth.handleResponse(0, responseBody);
	        if (status.authComplete)
	        {
	            if (status.authSuccess)
	            {
					loggedIn = true;
					restartStream();
	            }
	            else
	            {
					dispatchError("Authentication Error", "", "", 401);
	                disconnect();
	            }
	        }
	    }
	    
		/**
		 * @private
		 */
	    protected function restartStream():void
	    {
	        sendXML(openingStreamTag);
	    }
	    
		/**
		 * @private
		 */
	    protected function bindConnection():void 
	    {
	    	var bindIQ:IQ = new IQ(null, "set");
	
			var bindExt:BindExtension = new BindExtension();
			if(resource)
	        	bindExt.resource = resource;
	        
	        bindIQ.addExtension(bindExt);
	        
			bindIQ.callback = handleBindResponse;
			bindIQ.callbackScope = this;
	
	        send(bindIQ);
	    }
	    
		/**
		 * @private
		 */
	    protected function handleBindResponse(packet:IQ):void
	    {
	    	logger.debug("handleBindResponse: {0}", packet.getNode());
	    	var bind:BindExtension = packet.getExtension("bind") as BindExtension;
	
            var jid:UnescapedJID = bind.jid.unescaped;
            
            myResource = jid.resource;
            myUsername = jid.node;
            domain = jid.domain;
            
            establishSession();
	    }
	    
		/**
		 * @private
		 */
	    private function establishSession():void
	    {
	        var sessionIQ:IQ = new IQ(null, "set");

	        sessionIQ.addExtension(new SessionExtension());
	        
	        sessionIQ.callback = handleSessionResponse;
	        sessionIQ.callbackScope = this;
	
	        send(sessionIQ);
	    }
	    
		/**
		 * @private
		 */
	    private function handleSessionResponse(packet:IQ):void
	    {
	    	logger.debug("handleSessionResponse: {0}", packet.getNode());
			dispatchEvent(new LoginEvent());
	    }
		
		/**
		 * @private
		 */
		protected function addIQCallbackToPending( id:String, callbackName:String, callbackScope:Object, callbackFunc:Function ):void
		{
			pendingIQs[id] = {methodName:callbackName, methodScope:callbackScope, func:callbackFunc};
		}
		
		/**
		 * The XMPP server to use for connection.
		 */
		public function get server():String
		{
			if (!myServer)
				return myDomain;
			return myServer;
		}
		
		/**
		 * @private
		 */
		public function set server( theServer:String ):void
		{
			myServer = theServer;
		}
		
		/**
		 * The XMPP domain to use with the server.
		 */
		public function get domain():String
		{
			if (!myDomain)
				return myServer;
			return myDomain;
		}
		
		/**
		 * @private
		 */
		public function set domain( theDomain:String ):void
		{
			myDomain = theDomain;
		}
		
		/**
		 * The username to use for connection. If this property is null when <code>connect()</code> is called,
		 * the class will fetch registration field data rather than attempt to login.
		 */
		public function get username():String
		{
			return myUsername;
		}
		
		/**
		 * @private
		 */
		public function set username( theUsername:String ):void
		{
			myUsername = theUsername;
		}
		
		/**
		 * The password to use when logging in.
		 */
		public function get password():String
		{
			return myPassword;
		}
		
		public function set password( thePassword:String ):void
		{
			myPassword = thePassword;
		}
		
		/**
		 * The resource to use when logging in. A resource is required (defaults to "XIFF") and 
		 * allows a user to login using the same account simultaneously (most likely from multiple machines). 
		 * Typical examples of the resource include "Home" or "Office" to indicate the user's current location.
		 */
		public function get resource():String
		{
			return myResource;
		}
		
		/**
		 * @private
		 */
		public function set resource( theResource:String ):void
		{
			if( theResource.length > 0 )
			{
				myResource = theResource;
			}
		}
		
		/**
		 * Whether to use anonymous login or not.
		 */
		public function get useAnonymousLogin():Boolean 
		{ 
			return _useAnonymousLogin; 
		}
		
		/**
		 * @private
		 */
		public function set useAnonymousLogin(value:Boolean):void 
		{
			// set only if not connected
			if(!isActive()) _useAnonymousLogin = value;
		}
		
		/**
		 * The port to use when connecting. The default XMPP port is 5222.
		 */
		public function get port():Number
		{
			return myPort;
		}
		
		public function set port( portNum:Number ):void
		{
			myPort = portNum;
		}
	
		/**
		 * Determines whether whitespace will be ignored on incoming XML data.
		 * Behaves the same as <code>XML.ignoreWhite</code>
		 */
		public function get ignoreWhite():Boolean
		{
			return ignoreWhitespace;
		}
	
		public function set ignoreWhite( val:Boolean ):void
		{
			ignoreWhitespace = val;
		}
		
		private function _createXmlSocket():XMLSocket {
			var socket:XMLSocket = new XMLSocket(server, port);
			socket.addEventListener(Event.CONNECT,socketConnected);
			socket.addEventListener(IOErrorEvent.IO_ERROR,onIOError);
			socket.addEventListener(Event.CLOSE,socketClosed);
			socket.addEventListener(DataEvent.DATA,socketReceivedData);
			socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR,securityError);
			return socket;
		}
	}
}
