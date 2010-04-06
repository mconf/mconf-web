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
	import org.jivesoftware.xiff.data.Extension;
	import org.jivesoftware.xiff.data.ExtensionClassRegistry;
	import org.jivesoftware.xiff.data.IExtendable;
	import org.jivesoftware.xiff.data.IExtension;
	import org.jivesoftware.xiff.data.ISerializable;
	
	/**
	 * Implements the base functionality shared by all MUC extensions
	 *
	 * @author Sean Treadway
	 * @since 2.0.0
	 * @param parent (Optional) The containing XMLNode for this extension
	 * @availability Flash Player 7
	 * @toc-path Extensions/Conferencing
	 * @toc-sort 1/2
	 */
	public class MUCBaseExtension extends Extension implements IExtendable, ISerializable
	{
		private var myItems:Array = [];
	
		public function MUCBaseExtension( parent:XMLNode=null )
		{
			super(parent);
		}

		/**
		 * Called when this extension is being put back on the network.  Perform any further serialization for Extensions and items
		 */
		public function serialize( parent:XMLNode ):Boolean
		{
			var node:XMLNode = getNode();
	
			for each(var i:* in myItems) {
				if (!i.serialize(node)) {
					return false;
				}
			}
	
			var exts:Array = getAllExtensions();
			for each(var ii:* in exts) {
				if (!ii.serialize(node)) {
					return false;
				}
			}
	
			if (parent != node.parentNode) {
				parent.appendChild(node.cloneNode(true));
			}
	
			return true;
		}
	
		public function deserialize( node:XMLNode ):Boolean
		{
			setNode(node);
			removeAllItems();
	
			for each( var child:XMLNode in node.childNodes ) {
				switch( child.nodeName )
				{
					case "item":
						var item:MUCItem = new MUCItem(getNode());
						item.deserialize(child);
						myItems.push(item);
						break;
	
					default:
						var extClass:Class = ExtensionClassRegistry.lookup(child.attributes.xmlns);
						if (extClass != null) {
							var ext:IExtension = new extClass();
							if (ext != null) {
								if (ext is ISerializable) {
									ISerializable(ext).deserialize(child);
								}
								addExtension(ext);
							}
						}
						break;
				}
			}
			return true;
		}
	
		/**
		 * Item interface to MUCItems if they are contained in this extension
		 *
		 * @return Array of MUCItem objects
		 * @availability Flash Player 7
		 */
		public function getAllItems():Array
		{
			return myItems;
		}
	
		/**
		 * Use this method to create a new item.  Either the affiliation or role are requried.
		 *
		 * @param affiliation A predefined string defining the affiliation the JID or nick has in relation to the room
		 * @param role The role the jid or nick has in the room
		 * @param nick The nickname of the new item
		 * @param jid The jid of the new item
		 * @param actor The user that is actually creating the request
		 * @param reason The reason why the action associated with this item is being preformed
		 * @return The newly created MUCItem
		 * @availability Flash Player 7
		 */
		public function addItem(affiliation:String=null, role:String=null, nick:String=null, jid:EscapedJID=null, actor:String=null, reason:String=null):MUCItem
		{
			var item:MUCItem = new MUCItem(getNode());
	
			if (exists(affiliation)){ item.affiliation = affiliation; }
			if (exists(role)) 		{ item.role = role; }
			if (exists(nick)) 		{ item.nick = nick; }
			if (exists(jid)) 		{ item.jid = jid; }
			if (exists(actor)) 		{ item.actor = new EscapedJID(actor); }
			if (exists(reason)) 	{ item.reason = reason; }
			
			myItems.push(item);
			return item;
		}
		
		/**
		 * Use this method to remove all items.
		 *
		 * @availability Flash Player 7
		 */
		public function removeAllItems():void
		{
			for each(var i:* in myItems) {
				i.setNode(null);
			}
		 	myItems = [];
		}
	}
}