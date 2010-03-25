package org.jivesoftware.xiff.data.im{
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
	 * This class is used internally by the RosterExtension class for managing items
	 * received and sent as roster data. Usually, each item in the roster represents a single
	 * contact, and this class is used to represent, abstract, and serialize/deserialize
	 * this data.
	 *
	 * @author Sean Voisen
	 * @since 2.0.0
	 * @availability Flash Player 7
	 * @see org.jivesoftware.xiff.data.im.RosterExtension
	 * @param parent The parent XMLNode
	 * @toc-path Extensions/Instant Messaging
	 * @toc-sort 1/2
	 */
	public class RosterItem extends XMLStanza implements ISerializable
	{
		public static var ELEMENT:String = "item";
		
		private var myGroupNodes:Array;
		
		public function RosterItem( parent:XMLNode=null )
		{
			//<query xmlns="jabber:iq:roster"><item jid="herb@vaio.lymabean.com" subscription="both"><group>Buddies</group></item><item jid="alex@vaio.lymabean.com" subscription="both"><group>Co-workers</group></item><item jid="jack@vaio.lymabean.com" subscription="both"><group>Buddies</group></item></query>

			super();
			
			getNode().nodeName = ELEMENT;
			myGroupNodes = new Array();
			
			if( exists( parent ) ) {
				parent.appendChild( getNode() );
			}
		}
		
		/**
		 * Serializes the RosterItem data to XML for sending.
		 *
		 * @availability Flash Player 7
		 * @param parent The parent node that this item should be serialized into
		 * @return An indicator as to whether serialization was successful
		 */
		public function serialize( parent:XMLNode ):Boolean
		{
			if (!exists(jid)) {
				trace("Warning: required roster item attributes 'jid' missing");
				return false;
			}
			
			if( parent != getNode().parentNode ) {
				parent.appendChild( getNode().cloneNode( true ) );
			}
	
			return true;
		}
		
		/**
		 * Deserializes the RosterItem data.
		 *
		 * @availability Flash Player 7
		 * @param node The XML node associated this data
		 * @return An indicator as to whether deserialization was successful
		 */
		public function deserialize( node:XMLNode ):Boolean
		{
			setNode( node );
			
	
			var children:Array = node.childNodes;
			for( var i:String in children ) {
				switch( children[i].nodeName ) {
					case "group":
						myGroupNodes.push( children[i] );
						break;
				}
			}
			
			return true;
		}
		
		/**
		 * Adds a group to the roster item. Contacts in the roster can be associated
		 * with multiple groups.
		 *
		 * @availability Flash Player 7
		 * @param groupName The name of the group to add
		 */
		public function addGroupNamed( groupName:String ):void
		{
			var node:XMLNode = addTextNode( getNode(), "group", groupName );
			
			myGroupNodes.push( node );
		}
		
		/**
		 * Gets a list of all the groups associated with this roster item.
		 *
		 * @availability Flash Player 7
		 * @return An array of strings containing the name of each group
		 */
		public function get groupNames():Array
		{
			var returnArr:Array = new Array();

			for( var i:String in myGroupNodes ) {
				var node:XMLNode = myGroupNodes[i].firstChild;
				if(node != null){
					returnArr.push(node.nodeValue);
				}
				//returnArr.push(myGroupNodes[i].firstChild.nodeValue);

			}
			return returnArr;
		}
		
		public function get groupCount():Number
		{
			return myGroupNodes.length;
		}
		
		public function removeAllGroups():void
		{
			for( var i:String in myGroupNodes ) {
				myGroupNodes[i].removeNode();
			}
			
			myGroupNodes = new Array();
		}
		
		public function removeGroupByName( groupName:String ):Boolean
		{
			for( var i:String in myGroupNodes )
			{
				if( myGroupNodes[i].nodeValue == groupName ) {
					myGroupNodes[i].removeNode();
					myGroupNodes.splice( Number(i), 1 );
					return true;
				}
			}
			
			return false;
		}	
		
		/**
		 * The JID for this roster item.
		 *
		 * @availability Flash Player 7
		 */
		public function get jid():EscapedJID
		{
			return new EscapedJID(getNode().attributes.jid);
		}
		
		public function set jid( newJID:EscapedJID ):void
		{
			getNode().attributes.jid = newJID.toString();
		}
		
		/**
		 * The display name for this roster item.
		 *
		 * @availability Flash Player 7
		 */
		public function get name():String
		{
			return getNode().attributes.name;
		}
		
		public function set name( newName:String ):void
		{
			getNode().attributes.name = newName;
		}
		
		/**
		 * The subscription type for this roster item. Subscription types
		 * have been enumerated by static variables in the RosterExtension:
		 * <ul>
		 * <li>RosterExtension.SUBSCRIBE_TYPE_NONE</li>
		 * <li>RosterExtension.SUBSCRIBE_TYPE_TO</li>
		 * <li>RosterExtension.SUBSCRIBE_TYPE_FROM</li>
		 * <li>RosterExtension.SUBSCRIBE_TYPE_BOTH</li>
		 * <li>RosterExtension.SUBSCRIBE_TYPE_REMOVE</li>
		 * </ul>
		 *
		 * @availability Flash Player 7
		 */
		public function get subscription():String
		{
			return getNode().attributes.subscription;
		}
		
		public function set subscription( newSubscription:String ):void
		{
			getNode().attributes.subscription = newSubscription;
		}
		
		/**
		 * The ask type for this roster item.  Ask types have
		 * been enumerated by static variables in the RosterExtension:
		 * <ul>
		 * <li>RosterExtension.ASK_TYPE_NONE</li>
		 * <li>RosterExtension.ASK_TYPE_SUBSCRIBE</li>
		 * <li>RosterExtension.ASK_TYPE_UNSUBSCRIBE</li>
		 * </ul>
		 * 
		 * @availability Flash Player 7
		 */
		 public function get askType():String
		 {
		 	return getNode().attributes.ask;
		 }
		 
		 public function set askType( newAskType:String ):void
		 {
		 	getNode().attributes.ask = newAskType;
		 }
		 
		 /**
		 * Convenience routine to determine if a roster item is considered "pending" or not.
		 */
		 public function get pending():Boolean
		 {
		 	if (askType == RosterExtension.ASK_TYPE_SUBSCRIBE && (subscription == RosterExtension.SUBSCRIBE_TYPE_NONE || subscription == RosterExtension.SUBSCRIBE_TYPE_FROM)) {
		 		return true;
		 	}
		 	else {
		 		return false;
		 	}
		 }
	}
	
}