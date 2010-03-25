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
	import org.jivesoftware.xiff.conference.Room;
	import org.jivesoftware.xiff.core.Browser;
	import org.jivesoftware.xiff.core.EscapedJID;
	import org.jivesoftware.xiff.core.UnescapedJID;
	import org.jivesoftware.xiff.data.IQ;
	import org.jivesoftware.xiff.data.disco.InfoDiscoExtension;
	import org.jivesoftware.xiff.data.disco.ItemDiscoExtension;
	import org.jivesoftware.xiff.data.muc.MUCExtension;
	import org.jivesoftware.xiff.events.RoomEvent;
	
	public class MUCManager
	{
		private var observers:Object = {};
		private var serviceJIDsToServerJIDs:Object = {};
		private var rooms:Object = {};
		
		private static var sharedInstance:MUCManager = null;
		
		public static function get manager():MUCManager
		{
			if(!sharedInstance)
				sharedInstance = new MUCManager();
			return sharedInstance;
		}
		
		public function MUCManager()
		{
			super();
		}
		
		public function getRoom(roomJID:UnescapedJID, name:String=null):Room
		{
			var room:Room = rooms[roomJID.bareJID];
			if(!room)
			{
				room = new Room(SparkManager.connectionManager.connection);
				room.roomJID = roomJID;
				room.addEventListener(RoomEvent.ROOM_LEAVE, function(evt:RoomEvent):void {
					rooms[roomJID.bareJID] = null;
				});
				if(name)
					room.roomName = name;
				rooms[roomJID.bareJID] = room;
			}
			return room;
		}
		
		public function findConferenceService(server:UnescapedJID, callback:Function):void
		{
			if(!observers[server.toString()])
			{
				observers[server.toString()] = [];
			}
			observers[server.toString()].push(callback);
			new Browser(SparkManager.connectionManager.connection).getServiceInfo(server.escaped, "handleSpeculativeInfoReply", this);
		}
		
		public function handleSpeculativeInfoReply(iq:IQ):void
		{
			var extensions:Array = iq.getAllExtensionsByNS(InfoDiscoExtension.NS);
			if (!extensions || extensions.length < 1)
				return;
			
			for each(var feature:String in extensions[0].features)
			{
				if (feature == MUCExtension.NS)
				{
					for each(var callback:Function in observers[iq.from.unescaped.toString()])
					{
						callback(iq.from.unescaped);
					}
					return;
				}
			}
			//if it wasn't a conference server, we need to get the list of services on this server
			new Browser(SparkManager.connectionManager.connection).getServiceItems(iq.from, "handleServiceList", this);
		}
		
		public function handleServiceList(iq:IQ):void
		{
			var extensions:Array = iq.getAllExtensionsByNS(ItemDiscoExtension.NS);
			if (!extensions || extensions.length < 1) 
				return;
				
			var extension:ItemDiscoExtension = extensions[0];
			
			var server:UnescapedJID = iq.from.unescaped;
			
			for each(var item:Object in extension.items) 
			{
				serviceJIDsToServerJIDs[item.jid] = server;
				new Browser(SparkManager.connectionManager.connection).getServiceInfo(new EscapedJID(item.jid), "handleInfoReply", this);
			}
		}
		
		public function handleInfoReply(iq:IQ):void
		{
			var extensions:Array = iq.getAllExtensionsByNS(InfoDiscoExtension.NS);
			if (!extensions || extensions.length < 1)
				return;
			
			for each(var feature:String in extensions[0].features)
			{
				if (feature == MUCExtension.NS)
				{
					var server:UnescapedJID = serviceJIDsToServerJIDs[iq.from.toString()];
					for each(var callback:Function in observers[server.toString()])
					{
						callback(iq.from.unescaped);
					}
					return;
				}
			}
		}
	}
}