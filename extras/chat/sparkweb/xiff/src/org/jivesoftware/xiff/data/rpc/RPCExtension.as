package org.jivesoftware.xiff.data.rpc{
	/*
	 * Copyright (C) 2003-2007 
	 * Sean Voisen <sean@voisen.org>
	 * Sean Treadway <seant@oncotype.dk>
	 * Media Insites, Inc.
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
	
	import org.jivesoftware.xiff.data.Extension;
	import org.jivesoftware.xiff.data.ExtensionClassRegistry;
	import org.jivesoftware.xiff.data.IExtension;
	import org.jivesoftware.xiff.data.ISerializable;
	import org.jivesoftware.xiff.data.rpc.XMLRPC;
	import flash.xml.XMLNode;
	
	/**
	 * Implements <a href="http://www.jabber.org/jeps/jep-0009.html">JEP-0009<a> for XML-RPC over XMPP.
	 *
	 * @author Sean Treadway
	 * @since 2.0.0
	 * @availability Flash Player 7
	 * @toc-path Extensions/RPC
	 * @toc-sort 1/2
	 */
	public class RPCExtension extends Extension implements IExtension, ISerializable
	{
		// Static class variables to be overridden in subclasses;
		public static var NS:String = "jabber:iq:rpc";
		public static var ELEMENT:String = "query";
	
	    private static var staticDepends:Class = ExtensionClassRegistry;
	
		private var myResult:Array;
		private var myFault:Object;
	
		/**
		 * Place the remote call.  This method serializes the remote procedure call to XML.  
		 * The call will be made on the remote machine when the stanza containing this extension is sent to the server.
		 *
		 * If this extension is being returned, then check the result property instead.
		 *
		 * @param methodName The name of the remote procedure to call
		 * @param params A collection of parameters of any type
		 * @see #result
		 * @availability Flash Player 7
		 */
	
		public function call(methodName:String, params:Array):void
		{
			XMLRPC.toXML(getNode(), methodName, params);
		}
	
		/**
		 * The result of this remote procedure call.  It can contain elements of any type.
		 *
		 * @return Array of demarshalled results from the remote procedure
		 * @availability Flash Player 7
		 */
		public function get result():Array
		{
			return myResult;
		}
	
		/**
		 * Check this if property if you wish to determine the remote procedure call produced an error.
		 * If the XMPP stanza never made it to the RPC service, then the error would be on the stanza object instead of this extension.
		 *
		 * @return True if the remote procedure call produced an error
		 * @availability Flash Player 7
		 */
		public function get isFault():Boolean
		{
			return myFault.isFault;
		}
	
		/**
		 * The object containing the fault of the remote procedure call.  This object could have any properties, as fault results are only structurally defined.
		 *
		 * @availability Flash Player 7
		 */
		public function get fault():Object
		{
			return myFault;
		}
	
		/**
		 * A common result from most RPC servers to describe a fault
		 *
		 * @availability Flash Player 7
		 */
		public function get faultCode():Number 
		{
			return myFault.faultCode;
		}
	
		/**
		 * A common result from most RPC servers to describe a fault
		 *
		 * @availability Flash Player 7
		 */
		public function get faultString():String
		{
			return myFault.faultString;
		}
	
		/**
		 * Interface method, returning the namespace for this extension
		 *
		 * @see org.jivesoftware.xiff.data.IExtension
		 * @availability Flash Player 7
		 */
		public function getNS():String
		{
			return RPCExtension.NS;
		}
	
		/**
		 * Interface method, returning the namespace for this extension
		 *
		 * @see org.jivesoftware.xiff.data.IExtension
		 * @availability Flash Player 7
		 */
		public function getElementName():String
		{
			return RPCExtension.ELEMENT;
		}
	
	    /**
	     * Performs the registration of this extension into the extension registry.  
	     * 
		 * @availability Flash Player 7
	     */
	    public static function enable():void
	    {
	        ExtensionClassRegistry.register(RPCExtension);
	    }
	
		/**
		 * Interface method, returning the namespace for this extension
		 *
		 * @see org.jivesoftware.xiff.data.ISerializable
		 * @availability Flash Player 7
		 */
		public function serialize( parent:XMLNode ):Boolean
		{
			if (!exists(getNode().parentNode)) {
				parent.appendChild(getNode().cloneNode(true));
			}
			return true;
		}
	
		/**
		 * Interface method, returning the namespace for this extension
		 *
		 * @see org.jivesoftware.xiff.data.ISerializable
		 * @availability Flash Player 7
		 */
		public function deserialize( node:XMLNode ):Boolean
		{
			setNode(node);
	
			var res:Array = XMLRPC.fromXML(node);
			if (res.isFault) {
				myFault = res;
			} else {
				myResult = res[0];
			}
	
			return true;
		}
	
	}
}