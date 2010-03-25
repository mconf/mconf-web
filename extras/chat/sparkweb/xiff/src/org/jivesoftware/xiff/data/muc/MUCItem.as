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
	import org.jivesoftware.xiff.data.ISerializable;
	import org.jivesoftware.xiff.data.XMLStanza;
	
	/**
	 * This class is used by the MUCExtension for internal representation of
	 * information pertaining to occupants in a multi-user conference room.
	 *
	 * @author Sean Treadway
	 * @since 2.0.0
	 * @availability Flash Player 7
	 * @toc-path Extensions/Conferencing
	 * @toc-sort 1/2
	 */
	public class MUCItem extends XMLStanza implements ISerializable
	{
		public static var ELEMENT:String = "item";
	
		private var myActorNode:XMLNode;
		private var myReasonNode:XMLNode;
	
		public function MUCItem(parent:XMLNode=null)
		{
			super();
	
			getNode().nodeName = ELEMENT;
	
			if (exists(parent)) {
				parent.appendChild(getNode());
			}
		}
	
		public function serialize(parent:XMLNode):Boolean
		{
			if (parent != getNode().parentNode) {
				parent.appendChild(getNode().cloneNode(true));
			}
	
			return true;
		}
	
		public function deserialize(node:XMLNode):Boolean
		{
			setNode(node);
	
			var children:Array = node.childNodes;
			for( var i:String in children ) {
				switch( children[i].nodeName )
				{
					case "actor":
						myActorNode = children[i];
						break;
						
					case "reason":
						myReasonNode = children[i];
						break;
				}
			}
			return true;
		}
	
		public function get actor():EscapedJID
		{
			return new EscapedJID(myActorNode.attributes.jid);
		}
	
		public function set actor(val:EscapedJID):void
		{
			myActorNode = ensureNode(myActorNode, "actor");
			myActorNode.attributes.jid = val.toString();
		}
	
		public function get reason():String
		{
			return myReasonNode.firstChild.nodeValue;
		}
	
		public function set reason(val:String):void
		{
			myReasonNode = replaceTextNode(getNode(), myReasonNode, "reason", val);
		}
	
		public function get affiliation():String
		{
			return getNode().attributes.affiliation;
		}
	
		public function set affiliation(val:String):void
		{
			getNode().attributes.affiliation = val;
		}
	
		public function get jid():EscapedJID
		{
			if(getNode().attributes.jid == null)
				return null;
			return new EscapedJID(getNode().attributes.jid);
		}
	
		public function set jid(val:EscapedJID):void
		{
			getNode().attributes.jid = val.toString();
		}
	
		/**
		 * The nickname of the conference occupant.
		 *
		 * @availability Flash Player 7
		 */
		public function get nick():String
		{
			return getNode().attributes.nick;
		}
	
		public function set nick(val:String):void
		{
			getNode().attributes.nick = val;
		}
	
		public function get role():String
		{
			return getNode().attributes.role;
		}
	
		public function set role(val:String):void
		{
			getNode().attributes.role = val;
		}
	}
}