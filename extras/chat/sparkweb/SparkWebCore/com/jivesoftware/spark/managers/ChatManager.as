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
	import com.jivesoftware.spark.chats.SparkChat;
	import com.jivesoftware.spark.chats.SparkGroupChat;
	import com.jivesoftware.spark.events.ChatEvent;
	
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.jivesoftware.xiff.core.UnescapedJID;
	
	public class ChatManager extends EventDispatcher
	{
		private var chats:Object = {};
		private var queuedRooms:Array = [];
		private var autoJoinTimer:Timer;
		
		private static var _sharedInstance:ChatManager = null;
		
		public static function get sharedInstance():ChatManager
		{
			if(!_sharedInstance)
				_sharedInstance = new ChatManager();
			
			return _sharedInstance;
		}
		
		public function ChatManager()
		{
		}
		/**
		 * Starts a chat with a user
		 * @param jid the jid of the groupchat to join
		 * @param activate whether the chat should become the active chat
		 * @return the SparkGroupChat that was created, or null
		 */
		public function joinGroupChat(jid:UnescapedJID, activate:Boolean = true, password:String = null):SparkGroupChat
		{
			if(!jid)
				return null;
			var chat:SparkGroupChat = getChat(jid) as SparkGroupChat;
			if(!chat)
				chat = new SparkGroupChat(jid);
				
			chats[jid.bareJID] = chat;
				
			if (password != null)
				chat.password = password;
			
			var evt:ChatEvent = new ChatEvent(ChatEvent.CHAT_STARTED);
			evt.activate = activate;
			evt.chat = chat;
			dispatchEvent(evt);
			return chat;
		}
		
		/**
		 * Gets a chat
		 * @param jid the JID of the chat to get
		 */
		public function getChat(jid:UnescapedJID):SparkChat 
		{
			return chats[jid.bareJID];
		}
		
		/**
		 * Starts a chat with a user
		 * @param jid the jid to start the chat with
		 * @param activate whether the chat should become the active chat
		 * @return the SparkChat that was created, or null
		 */
		public function startChat(jid:UnescapedJID, activate:Boolean = true):SparkChat
		{
			if(!jid)
				return null;
			var chat:SparkChat = getChat(jid) as SparkChat;
			if(!chat)
				chat = new SparkChat(jid);
				
			chats[jid.bareJID] = chat;
			
			var evt:ChatEvent = new ChatEvent(ChatEvent.CHAT_STARTED);
			evt.activate = activate;
			evt.chat = chat;
			dispatchEvent(evt);
			return chat;
		}
		
		/**
		 * Closes a chat
		 * @param jid the JID of the chat to close
		 */
		public function closeChat(chat:SparkChat):void
		{
			var evt:ChatEvent = new ChatEvent(ChatEvent.CHAT_ENDED);
			evt.chat = chat;
			chat.close();
			dispatchEvent(evt);
			chats[chat.jid.bareJID] = null;
		}
		
		/**
		 * Queues a room for rate-limited auto-joining. This avoids perceived performance issues from blocking the UI
		 * @param jid the JID of the room to join
		 */
		public function queueRoom(jid:UnescapedJID):void
		{
			queuedRooms.push(jid);
			if(!autoJoinTimer)
			{
				autoJoinTimer = new Timer(3.0, 1);
				autoJoinTimer.addEventListener(TimerEvent.TIMER_COMPLETE, autoJoinRoom);
				autoJoinTimer.start();
			}
		}
			
		protected function autoJoinRoom(event:TimerEvent):void
		{
			if(queuedRooms.length == 0)
				return;
			
			joinGroupChat(queuedRooms.pop(), true);
			autoJoinTimer.reset();
			autoJoinTimer.start();
		}
	}
}