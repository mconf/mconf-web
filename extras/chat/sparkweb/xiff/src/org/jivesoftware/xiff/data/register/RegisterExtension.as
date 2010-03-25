package org.jivesoftware.xiff.data.register{
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
	
	import org.jivesoftware.xiff.data.ISerializable;
	import org.jivesoftware.xiff.data.IExtension;
	import org.jivesoftware.xiff.data.Extension;
	import org.jivesoftware.xiff.data.ExtensionClassRegistry;
	import flash.xml.XMLNode;
		
	/**
	 * Implements jabber:iq:register namespace.  Use this to create new accounts on the jabber server.
	 * Send an empty IQ.GET_TYPE packet with this extension and the return will either be a conflict, or the fields you will need to fill out.  
	 * Send a IQ.SET_TYPE packet to the server and with the fields that are listed in getRequiredFieldNames set on this extension.  
	 * Check the result and re-establish the connection with the new account.
	 *
	 * @author Sean Treadway
	 * @since 2.0.0
	 * @param parent (Optional) The parent node used to build the XML tree.
	 * @availability Flash Player 7
	 * @toc-path Extensions/Registration
	 * @toc-sort 1/2
	 */
	public class RegisterExtension extends Extension implements IExtension, ISerializable
	{
		// Static class variables to be overridden in subclasses;
		public static var NS:String = "jabber:iq:register";
		public static var ELEMENT:String = "query";
	
		private var myFields:Object;
		private var myKeyNode:XMLNode;
		private var myInstructionsNode:XMLNode;
		private var myRemoveNode:XMLNode;
	
	    private static var staticDepends:Class = ExtensionClassRegistry;
	
		public function RegisterExtension( parent:XMLNode=null )
		{
			super(parent);
			myFields = new Object();
		}
	
		public function getNS():String
		{
			return RegisterExtension.NS;
		}
	
		public function getElementName():String
		{
			return RegisterExtension.ELEMENT;
		}
	
	    /**
	     * Performs the registration of this extension into the extension registry.  
	     * 
		 * @availability Flash Player 7
	     */
	    public static function enable():void
	    {
	        ExtensionClassRegistry.register(RegisterExtension);
	    }
		
		public function serialize( parentNode:XMLNode ):Boolean
		{
			if (!exists(getNode().parentNode)) {
				parentNode.appendChild(getNode().cloneNode( true ));
			}
			return true;
		}
	
		public function deserialize( node:XMLNode ):Boolean
		{
			setNode(node);
	
			var children:Array = getNode().childNodes;
			for (var i:String in children) {
	
				switch (children[i].nodeName) {
					case "key":
						myKeyNode = children[i];
						break;
	
					case "instructions":
						myInstructionsNode = children[i];
						break;
	
					case "remove":
						myRemoveNode = children[i];
						break;
	
					default:
						myFields[children[i].nodeName] = children[i];
						break;
				}
			}
			return true;
	
		}
	
		public function get unregister():Boolean 
		{
			return exists(myRemoveNode);
		}
	
		public function set unregister(val:Boolean):void
		{
			myRemoveNode = replaceTextNode(getNode(), myRemoveNode, "remove", "");
		}
	
		public function getRequiredFieldNames():Array
		{
			var fields:Array = new Array();
	
			for (var i:String in myFields) {
				fields.push(i);
			}
	
			return fields;
		}
	
	
		public function get key():String 
		{ 
			return myKeyNode.firstChild.nodeValue; 
		}
	
		public function set key(val:String):void
		{
			myKeyNode = replaceTextNode(getNode(), myKeyNode, "key", val);
		}
	
		public function get instructions():String 
		{ 
			return myInstructionsNode.firstChild.nodeValue; 
		}
	
		public function set instructions(val:String):void
		{
			myInstructionsNode = replaceTextNode(getNode(), myInstructionsNode, "instructions", val);
		}
	
		public function getField(name:String):String
		{
			return myFields[name].firstChild.nodeValue;
		}
	
		public function setField(name:String, val:String):void
		{
			myFields[name] = replaceTextNode(getNode(), myFields[name], name, val);
		}
	
		public function get username():String { return getField("username"); }
		public function set username(val:String):void { setField("username", val); }
	
		public function get nick():String { return getField("nick"); }
		public function set nick(val:String):void { setField("nick", val); }
	
		public function get password():String { return getField("password"); }
		public function set password(val:String):void { setField("password", val); }
	
		public function get first():String { return getField("first"); }
		public function set first(val:String):void { setField("first", val); }
	
		public function get last():String { return getField("last"); }
		public function set last(val:String):void { setField("last", val); }
	
		public function get email():String { return getField("email"); }
		public function set email(val:String):void { setField("email", val); }
	
		public function get address():String { return getField("address"); }
		public function set address(val:String):void { setField("address", val); }
	
		public function get city():String { return getField("city"); }
		public function set city(val:String):void { setField("city", val); }
	
		public function get state():String { return getField("state"); }
		public function set state(val:String):void { setField("state", val); }
	
		public function get zip():String { return getField("zip"); }
		public function set zip(val:String):void { setField("zip", val); }
	
		public function get phone():String { return getField("phone"); }
		public function set phone(val:String):void { setField("phone", val); }
	
		public function get url():String { return getField("url"); }
		public function set url(val:String):void { setField("url", val); }
	
		public function get date():String { return getField("date"); }
		public function set date(val:String):void { setField("date", val); }
	
		public function get misc():String { return getField("misc"); }
		public function set misc(val:String):void { setField("misc", val); }
	
		public function get text():String { return getField("text"); }
		public function set text(val:String):void { setField("text", val); }
	}
}