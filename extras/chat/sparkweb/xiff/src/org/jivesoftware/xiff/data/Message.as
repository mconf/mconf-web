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
	 
package org.jivesoftware.xiff.data
{
	 
	import flash.xml.XMLNode;
	
	import org.jivesoftware.xiff.core.EscapedJID;
	import org.jivesoftware.xiff.data.muc.MUCUserExtension;
	import org.jivesoftware.xiff.data.xhtml.XHTMLExtension;
	
	/**
	 * A class for abstraction and encapsulation of message data.
	 *
	 * @param recipient The JID of the message recipient
	 * @param sender The JID of the message sender - the server should report an error if this is falsified
	 * @param msgID The message ID
	 * @param msgBody The message body in plain-text format
	 * @param msgHTMLBody The message body in XHTML format
	 * @param msgType The message type
	 * @param msgSubject (Optional) The message subject
	 */
	public class Message extends XMPPStanza implements ISerializable
	{
		
		// Static variables for specific type strings
		public static var NORMAL_TYPE:String = "normal";
		public static var CHAT_TYPE:String = "chat";
		public static var GROUPCHAT_TYPE:String = "groupchat";
		public static var HEADLINE_TYPE:String = "headline";
		public static var ERROR_TYPE:String = "error";
	
		// Private references to nodes within our XML
		private var myBodyNode:XMLNode;
		private var mySubjectNode:XMLNode;
		private var myThreadNode:XMLNode;
		private var myTimeStampNode:XMLNode;
			
		private static var isMessageStaticCalled:Boolean = MessageStaticConstructor();
		private static var staticConstructorDependency:Array = [ XMPPStanza, XHTMLExtension, ExtensionClassRegistry ];
	
		public function Message( recipient:EscapedJID=null, msgID:String=null, msgBody:String=null, msgHTMLBody:String=null, msgType:String=null, msgSubject:String=null )
		{
			// Flash gives a warning if superconstructor is not first, hence the inline id check
			var msgId:String = exists( msgID ) ? msgID : generateID("m_");
			super( recipient, null, msgType, msgId, "message" );
			body = msgBody;
			htmlBody = msgHTMLBody;
			subject = msgSubject;
		}
	
		public static function MessageStaticConstructor():Boolean
		{
			XHTMLExtension.enable();
			return true;
		}
	
		/**
		 * Serializes the Message into XML form for sending to a server.
		 *
		 * @return An indication as to whether serialization was successful
		 */
		override public function serialize( parentNode:XMLNode ):Boolean
		{
			return super.serialize( parentNode );
		}
	
		/**
		 * Deserializes an XML object and populates the Message instance with its data.
		 *
		 * @param xmlNode The XML to deserialize
		 * @return An indication as to whether deserialization was sucessful
		 */
		override public function deserialize( xmlNode:XMLNode ):Boolean
		{
			var isSerialized:Boolean = super.deserialize( xmlNode );
			if (isSerialized) {
				var children:Array = xmlNode.childNodes;
				for( var i:String in children )
				{
					switch( children[i].nodeName )
					{
						// Adding error handler for 404 sent back by server
						case "error":
							
							break;
						case "body":
							myBodyNode = children[i];
							break;
						
						case "subject":
							mySubjectNode = children[i];
							break;
							
						case "thread":
							myThreadNode = children[i];
							break;
							
						case "x":
							if(children[i].attributes.xmlns == "jabber:x:delay")
								myTimeStampNode = children[i];
							if(children[i].attributes.xmlns == MUCUserExtension.NS) {
								var mucUserExtension:MUCUserExtension = new MUCUserExtension(getNode());
								mucUserExtension.deserialize(children[i]);
								addExtension(mucUserExtension);
							}
							break;
					}
				}
			}
			return isSerialized;
		}
		
		/**
		 * The message body in plain-text format. If a client cannot render HTML-formatted
		 * text, this text is typically used instead.
		 */
		public function get body():String
		{
			if (!exists(myBodyNode)){
				return null;
			}
			var value: String = '';
			
			try
			{
				value =  myBodyNode.firstChild.nodeValue;				
			}
			
			catch (error:Error)
			{
				trace (error.getStackTrace());
			}
			return value;
		}
		
		/**
		 * @private
		 */
		public function set body( bodyText:String ):void
		{
			myBodyNode = replaceTextNode(getNode(), myBodyNode, "body", bodyText);
		}
		
		/**
		 * The message body in XHTML format. Internally, this uses the XHTML data extension.
		 *
		 * @see org.jivesoftware.xiff.data.xhtml.XHTMLExtension
		 */
		public function get htmlBody():String
		{
			try
			{
				var ext:XHTMLExtension = getAllExtensionsByNS(XHTMLExtension.NS)[0];
				return ext.body;
			}
			catch (e:Error)
			{
				trace("Error : null trapped. Resuming.");
			}
			return null;
		}
		
		/**
		 * @private
		 */
		public function set htmlBody( bodyHTML:String ):void
		{
			// Removes any existing HTML body text first
	        removeAllExtensions(XHTMLExtension.NS);
	
	        if (exists(bodyHTML) && bodyHTML.length > 0) {
	            var ext:XHTMLExtension = new XHTMLExtension(getNode());
	            ext.body = bodyHTML;
	            addExtension(ext);
	        }
		}
	
		/**
		 * The message subject. Typically chat and groupchat-type messages do not use
		 * subjects. Rather, this is reserved for normal and headline-type messages.
		 */
		public function get subject():String
		{
			if (mySubjectNode == null) return null;
			return mySubjectNode.firstChild.nodeValue;
		}
		
		/**
		 * @private
		 */
		public function set subject( aSubject:String ):void
		{
			mySubjectNode = replaceTextNode(getNode(), mySubjectNode, "subject", aSubject);
		}
	
		/**
		 * The message thread ID. Threading is used to group messages of the same discussion together.
		 * The library does not perform message grouping, rather it is up to any client authors to
		 * properly perform this task.
		 */
		public function get thread():String
		{
			if (myThreadNode == null) return null;
			return myThreadNode.firstChild.nodeValue;
		}
		
		/**
		 * @private
		 */
		public function set thread( theThread:String ):void
		{
			myThreadNode = replaceTextNode(getNode(), myThreadNode, "thread", theThread);
		}
		
		public function set time( theTime:Date ): void
		{
			
		}
		
		public function get time():Date 
		{
			if(myTimeStampNode == null) return null;
			var stamp:String = myTimeStampNode.attributes.stamp;
			
			var t:Date = new Date();
			//CCYYMMDDThh:mm:ss
			//20020910T23:41:07
			t.setUTCFullYear(stamp.slice(0, 4)); //2002
			t.setUTCMonth(Number(stamp.slice(4, 6)) - 1); //09 
			t.setUTCDate(stamp.slice(6, 8)); //10
											 //T
			t.setUTCHours(stamp.slice(9, 11)); //23
												//:
			t.setUTCMinutes(stamp.slice(12, 14)); //41
												//:
			t.setUTCSeconds(stamp.slice(15, 17)); //07
			return t;
		}
	}
}