package org.jivesoftware.xiff.data.muc{
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
	import org.jivesoftware.xiff.data.IExtension;
	
	/**
	 * Implements the base MUC user protocol schema from <a href="http://www.xmpp.org/extensions/xep-0045.html">XEP-0045<a> for multi-user chat.
	 *
	 * @author Sean Treadway
	 * @since 2.0.0
	 * @param parent (Optional) The containing XMLNode for this extension
	 * @availability Flash Player 7
	 * @toc-path Extensions/Conferencing
	 * @toc-sort 1/2
	 */
	public class MUCUserExtension extends MUCBaseExtension implements IExtension
	{
		// Static class variables to be overridden in subclasses;
		public static var NS:String = "http://jabber.org/protocol/muc#user";
		public static var ELEMENT:String = "x";
	
		public static var DECLINE_TYPE:String = "decline";
		public static var DESTROY_TYPE:String = "destroy";
		public static var INVITE_TYPE:String = "invite";
		public static var OTHER_TYPE:String = "other";
	
		private var myActionNode:XMLNode;
		private var myPasswordNode:XMLNode;
		private var myStatuses:Array = [];
	
		public function MUCUserExtension( parent:XMLNode=null )
		{
			super(parent);
		}
	
		public function getNS():String
		{
			return MUCUserExtension.NS;
		}
	
		public function getElementName():String
		{
			return MUCUserExtension.ELEMENT;
		}
	
		override public function deserialize( node:XMLNode ):Boolean
		{
			super.deserialize(node);
	
			for each( var child:XMLNode in node.childNodes ) {
				switch( child.nodeName )
				{
					case DECLINE_TYPE:
						myActionNode = child;
						break;
						
					case DESTROY_TYPE:
						myActionNode = child;
						break;
						
					case INVITE_TYPE:
						myActionNode = child;
						break;
						
					case "status":
						myStatuses.push(new MUCStatus(child, this));
						break;
						
					case "password":
						myPasswordNode = child;
						break;
				}
			}
			return true;
		}
	
		/**
		 * The type of user extension this is
		 */
		public function get type():String
		{
			if (myActionNode == null)
				return null;
			return myActionNode.nodeName == null ? OTHER_TYPE : myActionNode.nodeName;
		}
	
		/**
		 * The to property for invite and decline action types
		 */
		public function get to():EscapedJID
		{
			return new EscapedJID(myActionNode.attributes.to);
		}
	
		/**
		 * The from property for invite and decline action types
		 */
		public function get from():EscapedJID
		{
			return new EscapedJID(myActionNode.attributes.from);
		}
	
		/**
		 * The jid property for destroy the action type
		 */
		public function get jid():EscapedJID
		{
			return new EscapedJID(myActionNode.attributes.jid);
		}
	
	    /**
	     * The reason for the invite/decline/destroy
	     */
	    public function get reason():String
	    {
	    	if (myActionNode.firstChild != null) {
	    		if (myActionNode.firstChild.firstChild != null) {
	    			return myActionNode.firstChild.firstChild.nodeValue;
	    		}
	    	}
	        return null;
	    }
	
		/**
		 * Use this extension to invite another user
		 */
		public function invite(to:EscapedJID, from:EscapedJID, reason:String):void
		{
			updateActionNode(INVITE_TYPE, {to:to.toString(), from:from ? from.toString() : null}, reason);
		}
	
		/**
		 * Use this extension to destroy a room
		 */
		public function destroy(room:EscapedJID, reason:String):void
		{
			updateActionNode(DESTROY_TYPE, {jid: room.toString()}, reason);
		}
	
		/**
		 * Use this extension to decline an invitation
		 */
		public function decline(to:EscapedJID, from:EscapedJID, reason:String):void
		{
			updateActionNode(DECLINE_TYPE, {to:to.toString(), from:from ? from.toString() : null}, reason);
		}
	
		/**
		 * Property to use if the concerned room is password protected
		 */
		public function get password():String
		{
			if (myPasswordNode == null) return null;
			return myPasswordNode.firstChild.nodeValue;
		}
	
		public function set password(val:String):void
		{
			myPasswordNode = replaceTextNode(getNode(), myPasswordNode, "password", val);
		}
	
		
		public function get statuses():Array
		{
			return myStatuses;
		}
		
		public function set statuses(newStatuses:Array):void
		{
			myStatuses = newStatuses;
		}
		
		public function hasStatusCode(code:Number):Boolean
		{
			for each(var status:MUCStatus in statuses)
			{
				if(status.code == code)
					return true;
			}
			return false;
		}
			
		/**
		 * Internal method that manages the type of node that we will use for invite/destroy/decline messages
		 */
		private function updateActionNode(type:String, attrs:Object, reason:String) : void
		{
			if (myActionNode != null) myActionNode.removeNode();
	
			myActionNode = XMLFactory.createElement(type);
			for (var i:String in attrs) {
				if (exists(attrs[i])) {
					myActionNode.attributes[i] = attrs[i];
				}
			}
			getNode().appendChild(myActionNode);
	
			if (reason.length > 0) {
				replaceTextNode(myActionNode, undefined, "reason", reason);
			}
		}
	}
}