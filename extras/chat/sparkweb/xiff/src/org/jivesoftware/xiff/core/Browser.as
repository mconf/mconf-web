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
 
package org.jivesoftware.xiff.core
{	
	import org.jivesoftware.xiff.data.ExtensionClassRegistry;
	import org.jivesoftware.xiff.data.IQ;
	import org.jivesoftware.xiff.data.browse.BrowseExtension;
	import org.jivesoftware.xiff.data.disco.InfoDiscoExtension;
	import org.jivesoftware.xiff.data.disco.ItemDiscoExtension;
	
	/**
	 * Provides a means of querying for available services on an XMPP server using
	 * the Disco protocol extension. For more information on Disco, take a look at
	 * <a href="http://www.jabber.org/jeps/jep-0030.html">JEP-0030</a> and 
	 * <a href="http://www.jabber.org/jeps/jep-0011.html">JEP-0011</a> for the
	 * protocol enhancement specifications.
	 */
	public class Browser
	{
		private var _connection:XMPPConnection;
		private var _pending:Object;
	
		private static var _staticDepends:Array = [ ItemDiscoExtension, InfoDiscoExtension, BrowseExtension, ExtensionClassRegistry ];
		private static var _isEventEnabled:Boolean = BrowserStaticConstructor();
	
		/**
		 * @param conn A reference to the <code>XMPPConnection</code> instance
		 * to use.
		 */
		public function Browser( conn:XMPPConnection )
		{
			connection = conn;
			_pending = new Object();
		}
	
		private static function BrowserStaticConstructor():Boolean
		{
			ItemDiscoExtension.enable();
			InfoDiscoExtension.enable();
			BrowseExtension.enable();
			return true;
		}
	
		public function getNodeInfo(service:EscapedJID, node:String, callback:String, scope:Object):void
		{
			var iq:IQ = new IQ(service, IQ.GET_TYPE);
			var ext:InfoDiscoExtension = new InfoDiscoExtension(iq.getNode());
			ext.service = service;
			ext.serviceNode = node;
			iq.callbackName = callback;
			iq.callbackScope = scope;
			iq.addExtension(ext);
			connection.send(iq);
		}
	
		public function getNodeItems(service:EscapedJID, node:String, callback:String, scope:Object):void
		{
			var iq:IQ = new IQ(service, IQ.GET_TYPE);
			var ext:ItemDiscoExtension = new ItemDiscoExtension(iq.getNode());
			ext.service = service;
			ext.serviceNode = node;
			iq.callbackName = callback;
			iq.callbackScope = scope;
			iq.addExtension(ext);
			connection.send(iq);
		}
	
		/**
		 * Retrieves a list of available service information from the server specified. On successful query,
		 * the callback specified will be called and passed a single parameter containing
		 * a reference to an <code>IQ</code> containing the query results.
		 *
		 * @param server The server to query for available service information
		 * @param callback The name of a callback function to call when results are retrieved
		 * @param scope The scope of the callback function
		 */
		public function getServiceInfo(server:EscapedJID, callback:String, scope:Object):void
		{
			var iq:IQ = new IQ(server, IQ.GET_TYPE);
			iq.callbackName = callback;
			iq.callbackScope = scope;
			iq.addExtension(new InfoDiscoExtension(iq.getNode()));
			connection.send(iq);
		}
	
		/**
		 * Retrieves a list of available services items from the server specified. Items include things such
		 * as available transports and user directories. On successful query, the callback specified in the will be 
		 * called and passed a single parameter containing the query results.
		 *
		 * @param server The server to query for service items
		 * @param callback The name of a callback function to call when results are retrieved
		 * @param scope The scope of the callback function
		 */
		public function getServiceItems(server:EscapedJID, callback:String, scope:Object):void
		{
			var iq:IQ = new IQ(server, IQ.GET_TYPE);
			iq.callbackName = callback;
			iq.callbackScope = scope;
			iq.addExtension(new ItemDiscoExtension(iq.getNode()));
			connection.send(iq);
		}
	
		/**
		 * Use the <code>BrowseExtension</code> (jabber:iq:browse namespace) to query a 
		 * resource for supported features and children.
		 *
		 * @param id The full JabberID to query for service items
		 * @param callback The name of a callback function to call when results are retrieved
		 * @param scope The scope of the callback function
		 */
		public function browseItem(id:EscapedJID, callback:String, scope:Object):void
		{
			var iq:IQ = new IQ(id, IQ.GET_TYPE);
			iq.callbackName = callback;
			iq.callbackScope = scope;
			iq.addExtension(new BrowseExtension(iq.getNode()));
			connection.send(iq);
		}
	
		/**
		 * The instance of the XMPPConnection class to use for sending and receiving data.
		 */
		public function get connection():XMPPConnection { return _connection; }
		
		/**
		 * @private
		 */
		public function set connection(val:XMPPConnection):void { _connection=val; }
	}
	
}