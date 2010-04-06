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
	
package org.jivesoftware.xiff.data.disco
{

	import flash.xml.XMLNode;
	
	import org.jivesoftware.xiff.core.EscapedJID;
	import org.jivesoftware.xiff.data.Extension;
	import org.jivesoftware.xiff.data.ISerializable;
	
	/**
	 * Base class for service discovery extensions.
	 */
	public class DiscoExtension extends Extension implements ISerializable
	{
		// Static class variables to be overridden in subclasses;
		public static var NS:String = "http://jabber.org/protocol/disco";
		public static var ELEMENT:String = "query";
		
		public var myService:EscapedJID;
	
		/**
		 * The name of the resource of the service queried if the resource 
		 * doesn't have a JID. For more information, see 
		 * <a href="http://www.jabber.org/registrar/disco-nodes.html">
		 * http://www.jabber.org/registrar/disco-nodes.html</a>.
		 */
		public function DiscoExtension(xmlNode:XMLNode)
		{
			super(xmlNode);
		}
		
		public function get serviceNode():String 
		{ 
			return getNode().parentNode.attributes.node;
		}
	
		/**
		 * @private
		 */
		public function set serviceNode(val:String):void
		{
			getNode().parentNode.attributes.node = val;
		}
	
		/**
		 * The service name of the discovery procedure
		 */
		public function get service():EscapedJID
		{
			var parent:XMLNode = getNode().parentNode;
	
			if (parent.attributes.type == "result") {
				return new EscapedJID(parent.attributes.from);
			} else {
				return new EscapedJID(parent.attributes.to);
			}
		}
		
		/**
		 * @private
		 */
		public function set service(val:EscapedJID):void
		{
			var parent:XMLNode = getNode().parentNode;
	
			if (parent.attributes.type == "result") {
				parent.attributes.from = val.toString();
			} else {
				parent.attributes.to = val.toString();
			}
		}
	
		public function serialize(parentNode:XMLNode):Boolean
		{
			if (parentNode != getNode().parentNode) {
				parentNode.appendChild(getNode().cloneNode(true));
			}
			return true;
		}
	
		public function deserialize(node:XMLNode):Boolean
		{
			setNode(node);
			return true;
		}
	}
}