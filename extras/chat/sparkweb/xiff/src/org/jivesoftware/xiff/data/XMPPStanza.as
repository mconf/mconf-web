package org.jivesoftware.xiff.data{
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
	 
	import flash.xml.XMLNode;
	
	import org.jivesoftware.xiff.core.EscapedJID;
	import org.jivesoftware.xiff.data.id.IIDGenerator;
	import org.jivesoftware.xiff.data.id.IncrementalGenerator;
	
	/**
	 * The base class for all XMPP stanza data classes.
	 *
	 * @author Sean Voisen
	 * @since 2.0.0
	 * @availability Flash Player 7
	 * @toc-path Data/Base Classes
	 * @toc-sort 1/2
	 */
	public dynamic class XMPPStanza extends XMLStanza implements ISerializable, IExtendable
	{
		public static var CLIENT_NS:String = "jabber:client";

	
		private var myErrorNode:XMLNode;
		private var myErrorConditionNode:XMLNode;
	
		//private static var theIDGenerator:IIDGenerator = new IncrementalGenerator();
		private static var staticDependencies:* = [ IncrementalGenerator, ExtensionContainer ];
		private static var isStaticConstructed:* = XMPPStanzaStaticConstructor();
		
		public function XMPPStanza( recipient:EscapedJID, sender:EscapedJID, theType:String, theID:String, nName:String )
		{
			super();
			
			getNode().nodeName = nName;
			to = recipient;
			from = sender;
			type = theType;
			id = theID;
		}
	
		private static function XMPPStanzaStaticConstructor():void
		{
			//ExtensionContainer.decorate(XMPPStanza.prototype);
		}
	
		/**
		 * (Static method) Generates a unique ID for the stanza. ID generation is handled using
		 * a variety of mechanisms, but the default for the library uses the IncrementalGenerator.
		 *
		 * @see org.jivesoftware.xiff.data.id.IncrementalGenerator
		 * @availability Flash Player 7
		 * @param prefix The prefix for the ID to be generated
		 * @return The generated ID
		 */
		public static function generateID( prefix:String ):String
		{
			var id:String = IncrementalGenerator.getInstance().getID( prefix );
			return id;
		}
	
		/**
	 	 * (Static method) Sets the ID generator for this stanza type. ID generators must implement
		 * the IIDGenerator interface. The XIFF library comes with a few default
		 * ID generators that have already been implemented (see org.jivesoftware.xiff.data.id.*).
		 * 
		 * Setting the ID generator by stanza type is useful if you'd like to use
		 * different ID generation schemes for each type. For instance, messages could
		 * use the incremental ID generation scheme provided by the IncrementalGenerator class, while
		 * IQs could use the shared object ID generation scheme provided by the SharedObjectGenerator class.
		 *
		 * @availability Flash Player 7
		 * @param generator The ID generator class
		 * @example The following sets the ID generator for the Message stanza type to the IncrementalGenerator
		 * class found in org.jivesoftware.xiff.data.id.IncrementalGenerator:
		 * <pre>Message.setIDGenerator( org.jivesoftware.xiff.data.id.IncrementalGenerator );</pre>
		 */
		public static function setIDGenerator( generator:IIDGenerator ):void
		{
			//XMPPStanza.theIDGenerator = generator;
		}
	
		/**
		 * Prepares the XML version of the stanza for transmission to the server.
		 *
		 * @param parentNode (Optional) The parent node that the stanza should be appended to during serialization
		 * @return An indication as to whether serialization was successful
		 * @availability Flash Player 7
		 */
		public function serialize( parentNode:XMLNode ):Boolean
		{		
			var node:XMLNode = getNode();
			var exts:Array = getAllExtensions();
	
			for each(var ext:ISerializable in exts) {
				ext.serialize(node);
			}
	
			if (!exists(node.parentNode)) {
				node = node.cloneNode(true)
				parentNode.appendChild(node);
			}
	
			return true;
		}
		
		public function deserialize( xmlNode:XMLNode ):Boolean
		{
			setNode(xmlNode);
			
			var children:Array = xmlNode.childNodes;
			for( var i:String in children )
			{
				
				var nName:String = children[i].nodeName;
				var nNamespace:String = children[i].attributes.xmlns;
				
				nNamespace = exists( nNamespace ) ? nNamespace : CLIENT_NS;
				
				if( nName == "error" ) {
					myErrorNode = children[i];
					// If there is an error condition node, then we need that saved as well
					if( exists( myErrorNode.firstChild.nodeName ) ) {
						myErrorConditionNode = myErrorNode.firstChild;
					}
				}
				else {
					var extClass:Class = ExtensionClassRegistry.lookup(nNamespace);
					if (extClass != null) {
						var ext:IExtension = new extClass();
						ISerializable(ext).deserialize(children[i]);
						addExtension(ext);
					}
				}
			}
			return true;
		}
		
		/**
		 * The JID of the recipient.
		 *
		 * @availability Flash Player 7
		 */
		public function get to():EscapedJID
		{
			return new EscapedJID(getNode().attributes.to);
		}
		
		public function set to( recipient:EscapedJID ):void
		{
			delete getNode().attributes.to;
			if (exists(recipient)) { getNode().attributes.to = recipient.toString(); }
		}
		
		/**
		 * The JID of the sender. Most, if not all, server implementations follow the specifications
		 * that prevent this from being falsified. Thus, under normal circumstances, you don't
		 * need to supply this information because the server will fill it in automatically.
		 *
		 * @availability Flash Player 7
		 */
		public function get from():EscapedJID
		{
			return new EscapedJID(getNode().attributes.from);
		}
		
		public function set from( sender:EscapedJID ):void
		{
			delete getNode().attributes.from;
			if (exists(sender)) { getNode().attributes.from = sender.toString(); }
		}
		
		/**
		 * The stanza type. There are MANY types available, depending on what kind of stanza this is.
		 * The XIFF Library defines the types for IQ, Presence, and Message in each respective class
		 * as static string variables. Below is a listing of each:
		 * 
		 * <b>IQ</b>
		 * <ul>
		 * <li>IQ.SET_TYPE</li>
		 * <li>IQ.GET_TYPE</li>
		 * <li>IQ.RESULT_TYPE</li>
		 * <li>IQ.ERROR_TYPE</li>
		 * </ul>
		 *
		 * <b>Presence</b>
		 * <ul>
		 * <li>Presence.AVAILABLE_TYPE</li>
		 * <li>Presence.UNAVAILABLE_TYPE</li>
		 * <li>Presence.PROBE_TYPE</li>
		 * <li>Presence.SUBSCRIBE_TYPE</li>
		 * <li>Presence.UNSUBSCRIBE_TYPE</li>
		 * <li>Presence.SUBSCRIBED_TYPE</li>
		 * <li>Presence.UNSUBSCRIBED_TYPE</li>
		 * <li>Presence.ERROR_TYPE</li>
		 * </ul>
		 *
		 * <b>Message</b>
		 * <ul>
		 * <li>Message.NORMAL_TYPE</li>
		 * <li>Message.CHAT_TYPE</li>
		 * <li>Message.GROUPCHAT_TYPE</li>
		 * <li>Message.HEADLINE_TYPE</li>
		 * <li>Message.ERROR_TYPE</li>
		 * </ul>
		 *
		 * @availability Flash Player 7
		 */
		public function get type():String
		{
			return getNode().attributes.type;
		}
		
		public function set type( theType:String ):void
		{
			delete getNode().attributes.type;
			if (exists(theType)) { getNode().attributes.type = theType; }
		}
		
		/**
		 * The unique identifier of this stanza. ID generation is accomplished using
		 * the static <code>generateID</code> method.
		 *
		 * @availability Flash Player 7
		 * @see #generateID
		 */
		public function get id():String
		{
			return getNode().attributes.id;
		}
		
		public function set id( theID:String ):void
		{
			delete getNode().attributes.id;
			if (exists(theID)) { getNode().attributes.id = theID; }
		}
		
		/**
		 * The error message, assuming this stanza contains error information.
		 *
		 * @availability Flash Player 7
		 */
		public function get errorMessage():String
		{
			
			if( exists( errorCondition ) ) {
				//return myErrorConditionNode.firstChild.nodeValue;
				//return myErrorConditionNode.nextSibling.firstChild.nodeValue;  // fix recommended by bram 7/12/05
				return errorCondition.toString();
			}
			else {
				return myErrorNode.firstChild.nodeValue;
			}
			
		}
		
		public function set errorMessage( theMsg:String ):void
		{
			myErrorNode = ensureNode( myErrorNode, "error" );
			
			theMsg = exists( theMsg ) ? theMsg : "";
			
			if( exists( errorCondition ) ) {
				myErrorConditionNode = replaceTextNode( myErrorNode, myErrorConditionNode, errorCondition, theMsg );
			}
			else {
				var attributes:Object = myErrorNode.attributes;
				myErrorNode = replaceTextNode( getNode(), myErrorNode, "error", theMsg );
				myErrorNode.attributes = attributes;
			}
		}
		
		/**
		 * The error condition, assuming this stanza contains error information. For more information
		 * on error conditions, see <a href="http://www.jabber.org/jeps/jep-0086.html">http://www.jabber.org/jeps/jep-0086.html</a>.
		 *
		 * @availability Flash Player 7
		 */
		public function get errorCondition():String
		{
			if( exists( myErrorConditionNode ) ) {
				return myErrorConditionNode.nodeName;
			}
			
			return null;
		}
		
		public function set errorCondition( aCondition:String ):void
		{
			myErrorNode = ensureNode( myErrorNode, "error" );
			
			// A message might exist, so remove it first
			var attributes:Object = myErrorNode.attributes;
			var msg:String = errorMessage;
			
			if( exists( aCondition ) ) {
				myErrorNode = replaceTextNode( getNode(), myErrorNode, "error", "" );
				myErrorConditionNode = addTextNode( myErrorNode, aCondition, msg );
			}
			else {
				myErrorNode = replaceTextNode( getNode(), myErrorNode, "error", msg );
			}
			
			myErrorNode.attributes = attributes;
		}
		
		/**
		 * The error type, assuming this stanza contains error information. For more information
		 * on error types, see <a href="http://www.jabber.org/jeps/jep-0086.html">http://www.jabber.org/jeps/jep-0086.html</a>.
		 *
		 * @availability Flash Player 7
		 */
		public function get errorType():String
		{
			return myErrorNode.attributes.type;
		}
		
		public function set errorType( aType:String ):void
		{
			myErrorNode = ensureNode( myErrorNode, "error" );
			
			delete myErrorNode.attributes.type;
			if( exists( aType ) ) { myErrorNode.attributes.type = aType; }
		}
		
		/**
		 * The error code, assuming this stanza contains error information. Error codes are 
		 * deprecated in standard XMPP, but they are commonly used by older Jabber servers 
		 * like Jabberd 1.4. For more information on error codes, and corresponding error
		 * conditions, see <a href="http://www.jabber.org/jeps/jep-0086.html">http://www.jabber.org/jeps/jep-0086.html</a>.
		 *
		 * @availability Flash Player 7
		 */
		public function get errorCode():Number
		{
			return Number( myErrorNode.attributes.code );
		}
		
		public function set errorCode( aCode:Number ):void
		{
			myErrorNode = ensureNode( myErrorNode, "error" );
			
			delete myErrorNode.attributes.code;
			if( exists( aCode ) ) { myErrorNode.attributes.code = aCode; }
		}
	}
}