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
	
	/**
	 * This class provides encapsulation for manipulation of presence data for sending and receiving.
	 *
	 * @author Sean Voisen
	 * @since 2.0.0
	 * @availability Flash Player 7
	 * @param recipient The recipient of the presence, usually in the form of a JID.
	 * @param sender The sender of the presence, usually in the form of a JID.
	 * @param presenceType The type of presence as a string. There are predefined static variables for this.
	 * @param showVal What to show for this presence (away, online, etc.) There are predefined static variables for this.
	 * @param statusVal The status; usually used for the "away message."
	 * @param priorityVal The priority of this presence; usually on a scale of 1-5.
	 * @toc-path Data
	 * @toc-sort 1
	 */
	public class Presence extends XMPPStanza implements ISerializable 
	{
		// Static constants for specific type strings
		public static const UNAVAILABLE_TYPE:String = "unavailable";
		public static const PROBE_TYPE:String = "probe";
		public static const SUBSCRIBE_TYPE:String = "subscribe";
		public static const UNSUBSCRIBE_TYPE:String = "unsubscribe";
		public static const SUBSCRIBED_TYPE:String = "subscribed";
		public static const UNSUBSCRIBED_TYPE:String = "unsubscribed";
		public static const ERROR_TYPE:String = "error";
		
		// Static constants for show values
		public static const SHOW_AWAY:String = "away";
		public static const SHOW_CHAT:String = "chat";
		public static const SHOW_DND:String = "dnd";
		public static const SHOW_XA:String = "xa";
	
		// Private node references for property lookups
		private var myShowNode:XMLNode;
		private var myStatusNode:XMLNode;
		private var myPriorityNode:XMLNode;
	
	
		public function Presence( recipient:EscapedJID=null, sender:EscapedJID=null, presenceType:String=null, showVal:String=null, statusVal:String=null, priorityVal:Number=0 ) 
		{		
			super( recipient, sender, presenceType, null, "presence" );
			
			show = showVal;
			status = statusVal;
			priority = priorityVal;
		}
		
		/**
		 * Serializes the Presence into XML form for sending to a server.
		 *
		 * @return An indication as to whether serialization was successful
		 * @availability Flash Player 7
		 */
		override public function serialize( parentNode:XMLNode ):Boolean 
		{
			return super.serialize( parentNode );
		}
		
		/**
		 * Deserializes an XML object and populates the Presence instance with its data.
		 *
		 * @param xmlNode The XML to deserialize
		 * @return An indication as to whether deserialization was sucessful
		 * @availability Flash Player 7
		 */
		override public function deserialize( xmlNode:XMLNode ):Boolean 
		{	
			var isDeserialized:Boolean = super.deserialize( xmlNode );
			
			if (isDeserialized) { 
				var children:Array = xmlNode.childNodes;
				for( var i:String in children ) 
				{
					switch( children[i].nodeName ) 
					{
						case "show":
							myShowNode = children[i];
							break;
							
						case "status":
							myStatusNode = children[i];
							break;
							
						case "priority":
							myPriorityNode = children[i];
							break;
					}
				}
			}
			return isDeserialized;
		}
		
		/**
		 * The show value; away, online, etc. There are predefined static variables in the Presence
		 * class for this:
		 * <ul>
		 * <li>Presence.SHOW_AWAY</li>
		 * <li>Presence.SHOW_CHAT</li>
		 * <li>Presence.SHOW_DND</li>
		 * <li>Presence.SHOW_XA</li>
		 * </ul>
		 *
		 * @availability Flash Player 7
		 */
		public function get show():String 
		{
			if (!myShowNode || !exists(myShowNode.firstChild)) return null;
			
			return myShowNode.firstChild.nodeValue;
		}
		
		public function set show( showVal:String ):void 
		{
			if(showVal != SHOW_AWAY
			&& showVal != SHOW_CHAT
			&& showVal != SHOW_DND
			&& showVal != SHOW_XA
			&& showVal != null
			&& showVal != "")
				throw new Error("Invalid show value: " + showVal + " for presence");
			
			if(myShowNode && (showVal == null || showVal == ""))
			{
				myShowNode.removeNode();
				myShowNode = null;
			}
			myShowNode = replaceTextNode(getNode(), myShowNode, "show", showVal);
		}
		
		/**
		 * The status; usually used for "away messages."
		 *
		 * @availability Flash Player 7
		 */
		public function get status():String  {
			if (myStatusNode == null || myStatusNode.firstChild == null) return null;
			return myStatusNode.firstChild.nodeValue;
		}
		
		public function set status( statusVal:String ):void 
		{
			myStatusNode = replaceTextNode(getNode(), myStatusNode, "status", statusVal);
		}
		
		/**
		 * The priority of the presence, usually on a scale of 1-5.
		 *
		 * @availability Flash Player 7
		 */
		public function get priority():Number 
		{
			if (myPriorityNode == null) return NaN;
			var p:Number = Number(myPriorityNode.firstChild.nodeValue);
			if( isNaN( p ) ) {
				return NaN;
			}
			else {
				return p;
			}
		}
		
		public function set priority( priorityVal:Number ):void 
		{
			myPriorityNode = replaceTextNode(getNode(), myPriorityNode, "priority", priorityVal.toString());
		}
	}
}