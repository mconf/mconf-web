/*
 * Copyright (C) 2003-2007 
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
	 
package org.jivesoftware.xiff.data.auth
{	
	import org.jivesoftware.xiff.data.IExtension;
	import org.jivesoftware.xiff.data.ISerializable;
	
	import org.jivesoftware.xiff.data.Extension;
	import org.jivesoftware.xiff.data.ExtensionClassRegistry;
	import org.jivesoftware.xiff.data.auth.SHA1;
	
	import flash.xml.XMLNode;
	import org.jivesoftware.xiff.data.XMLStanza;
	
	/**
	 * Implements <a href="http://www.jabber.org/jeps/jep-0078.html">JEP-0078<a> 
	 * for non SASL authentication.
	 */
	public class AuthExtension extends Extension implements IExtension, ISerializable
	{
		// Static class variables to be overridden in subclasses;
		public static var NS:String = "jabber:iq:auth";
		public static var ELEMENT:String = "query";
	
		private var myUsernameNode:XMLNode;
		private var myPasswordNode:XMLNode;
		private var myDigestNode:XMLNode;
		private var myResourceNode:XMLNode;
		
		public function AuthExtension( parent:XMLNode = null)
		{
			super(parent);
		}
	
		/**
		 * Gets the namespace associated with this extension.
		 * The namespace for the AuthExtension is "jabber:iq:auth".
		 *
		 * @return The namespace
		 */
		public function getNS():String
		{
			return AuthExtension.NS;
		}
	
		/**
		 * Gets the element name associated with this extension.
		 * The element for this extension is "query".
		 *
		 * @return The element name
		 */
		public function getElementName():String
		{
			return AuthExtension.ELEMENT;
		}
	
	    /**
	     * Registers this extension with the extension registry.  
	     */
	    public static function enable():void
	    {
	        ExtensionClassRegistry.register(AuthExtension);
	    }
		
		public function serialize( parent:XMLNode ):Boolean
		{
			if (!exists(getNode().parentNode)) {
				parent.appendChild(getNode().cloneNode(true));
			}
			return true;
		}
	
		public function deserialize( node:XMLNode ):Boolean
		{
			
			setNode(node);
			var children:Array = node.childNodes;
			for( var i:String in children ) {
				switch( children[i].nodeName )
				{
					case "username":
						myUsernameNode = children[i];
						break;
						
					case "password":
						myPasswordNode = children[i];
						break;
						
					case "digest":
						myDigestNode = children[i];
						break;
	
					case "resource":
						myResourceNode = children[i];
						break;
				}
			}
			return true;
		}
	
		/**
		 * Computes the SHA1 digest of the password and session ID for use when 
		 * authenticating with the server.
		 *
		 * @param sessionID The session ID provided by the server
		 * @param password The user's password
		 */
		public static function computeDigest( sessionID:String, password:String ):String
		{
			return SHA1.calcSHA1( sessionID + password ).toLowerCase();
		}
	
		/**
		 * Determines whether this is a digest (SHA1) authentication.
		 *
		 * @return It is a digest (true); it is not a digest (false)
		 */
		public function isDigest():Boolean 
		{ 
			return exists(myDigestNode); 
		}
	
		/**
		 * Determines whether this is a plain-text password authentication.
		 *
		 * @return It is plain-text password (true); it is not plain-text 
		 * password (false)
		 */
		public function isPassword():Boolean 
		{ 
			return exists(myPasswordNode); 
		}
	
		/**
		 * The username to use for authentication.
		 */
		public function get username():String 
		{ 
			return myUsernameNode.firstChild.nodeValue; 
		}
	
		/**
		 * @private
		 */
		public function set username(val:String):void 
		{ 
			myUsernameNode = replaceTextNode(getNode(), myUsernameNode, "username", val);
		}
	
		/**
		 * The password to use for authentication.
		 */
		public function get password():String 
		{ 
			return myPasswordNode.firstChild.nodeValue;
		}
	
		/**
		 * @private
		 */
		public function set password(val:String):void
		{
			// Either or for digest or password
			myDigestNode = (myDigestNode==null)?(XMLStanza.XMLFactory.createElement('')):(myDigestNode);
			myDigestNode.removeNode();
			myDigestNode = null;
			//delete myDigestNode;
	
			myPasswordNode = replaceTextNode(getNode(), myPasswordNode, "password", val);
		}
	
		/**
		 * The SHA1 digest to use for authentication.
		 */
		public function get digest():String 
		{ 
			return myDigestNode.firstChild.nodeValue;
		}
	
		/**
		 * @private
		 */
		public function set digest(val:String):void
		{
			// Either or for digest or password
			myPasswordNode.removeNode();
			myPasswordNode = null;
			//delete myPasswordNode;
	
			myDigestNode = replaceTextNode(getNode(), myDigestNode, "digest", val);
		}
	
		/**
		 * The resource to use for authentication.
		 *
		 * @see org.jivesoftware.xiff.core.XMPPConnection#resource
		 */
		public function get resource():String 
		{ 
			return myResourceNode.firstChild.nodeValue 
		}
	
		/**
		 * @private
		 */
		public function set resource(val:String):void
		{
			myResourceNode = replaceTextNode(getNode(), myResourceNode, "resource", val);
		}
	
	}
}