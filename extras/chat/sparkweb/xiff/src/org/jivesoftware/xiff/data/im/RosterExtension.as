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
	import org.jivesoftware.xiff.data.Extension;
	import org.jivesoftware.xiff.data.ExtensionClassRegistry;
	import org.jivesoftware.xiff.data.IExtension;
	import org.jivesoftware.xiff.data.ISerializable;
	 
	/**
	 * An IQ extension for roster data. Roster data is typically any data
	 * that is sent or received with the "jabber:iq:roster" namespace.
	 *
	 * @author Sean Voisen
	 * @since 2.0.0
	 * @availability Flash Player 7
	 * @param theRoot The extension root
	 * @param theNode The extension node
	 * @toc-path Extensions/Instant Messaging
	 * @toc-sort 1/2
	 */
	public class RosterExtension extends Extension implements IExtension, ISerializable
	{
		// Static class variables to be overridden in subclasses;
		public static var NS:String = "jabber:iq:roster";
		public static var ELEMENT:String = "query";
		
		public static var SUBSCRIBE_TYPE_NONE:String = "none";
		public static var SUBSCRIBE_TYPE_TO:String = "to";
		public static var SUBSCRIBE_TYPE_FROM:String = "from";
		public static var SUBSCRIBE_TYPE_BOTH:String = "both";
		public static var SUBSCRIBE_TYPE_REMOVE:String = "remove";
		public static var ASK_TYPE_NONE:String = "none";
		public static var ASK_TYPE_SUBSCRIBE:String = "subscribe";
		public static var ASK_TYPE_UNSUBSCRIBE:String = "unsubscribe";
		public static var SHOW_UNAVAILABLE:String = "unavailable";
		public static var SHOW_PENDING:String = "Pending";
		
	    private static var staticDepends:Array = [ExtensionClassRegistry];
	
		private var myItems:Array = [];
		
		public function RosterExtension( parent:XMLNode=null )
		{
			super( parent );
		}
	
		/**
		 * Gets the namespace associated with this extension.
		 * The namespace for the RosterExtension is "jabber:iq:roster".
		 *
		 * @return The namespace
		 * @availability Flash Player 7
		 */
		public function getNS():String
		{
			return RosterExtension.NS;
		}
	
		/**
		 * Gets the element name associated with this extension.
		 * The element for this extension is "query".
		 *
		 * @return The element name
		 * @availability Flash Player 7
		 */
		public function getElementName():String
		{
			return RosterExtension.ELEMENT;
		}
		
	    /**
	     * Performs the registration of this extension into the extension registry.  
	     * 
		 * @availability Flash Player 7
	     */
	    public static function enable():void
	    {
	        ExtensionClassRegistry.register(RosterExtension);
	    }
	
		/**
		 * Serializes the RosterExtension data to XML for sending.
		 *
		 * @availability Flash Player 7
		 * @param parent The parent node that this extension should be serialized into
		 * @return An indicator as to whether serialization was successful
		 */
		public function serialize( parent:XMLNode ):Boolean
		{
			var node:XMLNode = getNode();
			
			// Serialize each roster item
			for( var i:String in myItems ) {
				if( !myItems[i].serialize( node ) ){
					return false;
				}
			}
			
			if( !exists( getNode().parentNode ) ) {
				parent.appendChild( getNode().cloneNode( true ) );
			}
			
			return true;
		}
		
		/**
		 * Deserializes the RosterExtension data.
		 *
		 * @availability Flash Player 7
		 * @param node The XML node associated this data
		 * @return An indicator as to whether deserialization was successful
		 */
		public function deserialize( node:XMLNode ):Boolean
		{
			setNode( node );
			removeAllItems();
			
			var children:Array = node.childNodes;
			for( var i:String in children ){
				switch( children[i].nodeName ) {
					case "item":
						var item:RosterItem = new RosterItem( getNode() );
						if( !item.deserialize( children[i] ) ) {
							return false;
						}
						myItems.push( item );
						break;
				}
			}
			
			return true;
		}
		
		/**
		 * Get all the items from this roster query.
		 *
		 * @return An array of roster items.
		 * @availability Flash Player 7
		 */
		public function getAllItems():Array
		{
			return myItems;
		}
		
		/**
		 * Gets one item from the roster query, returning the first item found with the JID specified. If none is found, then it returns null.
		 *
		 * @return A roster item object with the following attributes: "jid", "subscription", "displayName", and "groups".
		 * @availability Flash Player 7
		 */
		public function getItemByJID( jid:EscapedJID ):RosterItem
		{
			for( var i:String in myItems ) {
				if( myItems[i].jid == jid.toString() ) {
					return myItems[i];
				}
			}
			
			return null;
		}
		
		/**
		 * Adds a single roster item to the extension payload.
		 *
		 * @param jid The JID of the contact to add
		 * @param subscription The subscription type of the roster item contact. There are pre-defined static variables for these string options in this class definition.
		 * @param displayName The display name or nickname of the contact.
		 * @param groups An array of strings of the group names that this contact should be placed in.
		 * @availability Flash Player 7
		 */
		public function addItem( jid:EscapedJID=null, subscription:String="", displayName:String="", groups:Array=null ):void
		{
			var item:RosterItem = new RosterItem( getNode() );
			
			if( exists( jid ) ) { item.jid = jid }
			if( exists( subscription ) ) { item.subscription = subscription; }
			if( exists( displayName ) ) { item.name = displayName; }
			if( exists( groups ) ) {
				for each( var group:String in groups ) {
					item.addGroupNamed( group );
				}
			}
		}
		
		/**
		 * Removes all items from the roster data.
		 *
		 * @availability Flash Player 7
		 */
		public function removeAllItems():void
		{
			for( var i:String in myItems ) {
				myItems[i].setNode( null );
			}
			
			myItems = new Array();
		}
	}
}