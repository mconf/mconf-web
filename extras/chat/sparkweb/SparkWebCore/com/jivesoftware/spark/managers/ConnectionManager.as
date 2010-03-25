/*
 *This file is part of SparkWeb.
 *
 *SparkWeb is free software: you can redistribute it and/or modify
 *it under the terms of the GNU Lesser General Public License as published by
 *the Free Software Foundation, either version 3 of the License, or
 *(at your option) any later version.
 *
 *SparkWeb is distributed in the hope that it will be useful,
 *but WITHOUT ANY WARRANTY; without even the implied warranty of
 *MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *GNU Lesser General Public License for more details.
 *
 *You should have received a copy of the GNU Lesser General Public License
 *along with SparkWeb.  If not, see <http://www.gnu.org/licenses/>.
 */

package com.jivesoftware.spark.managers 
{	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.jivesoftware.xiff.core.EscapedJID;
	import org.jivesoftware.xiff.core.UnescapedJID;
	import org.jivesoftware.xiff.core.XMPPBOSHConnection;
	import org.jivesoftware.xiff.core.XMPPConnection;
	import org.jivesoftware.xiff.core.XMPPSocketConnection;
	import org.jivesoftware.xiff.data.Message;
	import org.jivesoftware.xiff.data.Presence;
	import org.jivesoftware.xiff.data.events.MessageEventExtension;
	import org.jivesoftware.xiff.data.im.RosterItemVO;
	import org.jivesoftware.xiff.events.LoginEvent;
	
	
	/**
	 * Responsible for the delegation of messages and presences.
	 */
	public class ConnectionManager extends EventDispatcher 
	{
		private var con:XMPPConnection;
		private var keepAliveTimer:Timer;
		private var _lastSent:int = 0;
		
		/**
		 * Creates a new instance of the ConnectionManager.
		 */
		public function ConnectionManager():void 
		{
			var type:String = SparkManager.getConfigValueForKey("connectionType");
			switch(type)
			{
				case "http":
					con = new XMPPBOSHConnection(false);
					break;
				case "https":
					con = new XMPPBOSHConnection(true);
					break;
				case "socket":
				default:
					con = new XMPPSocketConnection();	
			}
			if(SparkManager.getConfigValueForKey("port") != null)
				con.port = Number(SparkManager.getConfigValueForKey("port"));
		}
		
		/**
		 * Log into server.
		 * @param username the username of the account.
		 * @param password the user password.
		 * @param domain the server domain.
		 * @param resource an optional resource to connect with
		 * @param server an optional specific server hostname to connect to (otherwise domain will be used for connection)
		 * @param port an optional specific port to connect to (otherwise default will be used, 5222 for tcp, 8080 for http binding, 8443 for https binding)
		 */
		public function login(username:String, password:String, domain:String, resource:String="sparkweb", server:String=null):void 
		{
			con.username = username;
			con.password = password;
			con.domain = domain;
			con.resource = resource;
			if (server)
				con.server = server;
			
			con.removeEventListener("outgoingData", packetSent); 
			con.addEventListener("outgoingData", packetSent);
			con.connect( "terminatedStandard");
				
			con.removeEventListener(LoginEvent.LOGIN, getMe);
			con.addEventListener(LoginEvent.LOGIN, getMe);
			
			if(keepAliveTimer)
				keepAliveTimer.stop();
			keepAliveTimer = new Timer(15000);
			keepAliveTimer.addEventListener(TimerEvent.TIMER, checkKeepAlive);
			keepAliveTimer.start();
		}
		
		/**
		 * Logs out of the server.
		 */
		public function logout():void
		{
			// Send an unavilable presence
			var recipient:EscapedJID = new EscapedJID(connection.domain);
			var unavailablePresence:Presence = new Presence(recipient, null, Presence.UNAVAILABLE_TYPE, null, "Logged out");
			con.send(unavailablePresence);
			
			// Now disconnect
			con.disconnect();
		}
		
		private function getMe(evt:LoginEvent):void
		{
			SparkManager.me = RosterItemVO.get(con.jid, true);
		}
		
		/**
		 * Do a simple keep alive.
		 */
		public function checkKeepAlive(event:TimerEvent):void 
		{
			if(new Date().getTime() - _lastSent > 15000)
				con.sendKeepAlive();
		}
		
		public function packetSent(event:Event):void {
			_lastSent = new Date().getTime();
		}
		
		
		/**
		 * Returns the XMPPConnection used for this session.
		 * @return the XMPPConnection.
		 */	
		public function get connection():XMPPConnection {
			return con;
		}
		
		/**
		 * Sends a single message to a user.
		 * @param jid the jid to send the message to.
		 * @param body the body of the message to send.
		 */
		public function sendMessage(jid:UnescapedJID, body:String):void 
		{
			var message:Message = new Message();
			message.addExtension(new MessageEventExtension());
			message.to = jid.escaped;
			message.body = body;
			message.type = Message.CHAT_TYPE;
			con.send(message);
		}
	}
}
