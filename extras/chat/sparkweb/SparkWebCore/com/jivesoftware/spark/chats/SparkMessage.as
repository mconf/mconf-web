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

package com.jivesoftware.spark.chats
{
	import org.jivesoftware.xiff.core.UnescapedJID;
	import org.jivesoftware.xiff.data.Message;
	import org.jivesoftware.xiff.data.im.RosterItemVO;
	
	public class SparkMessage {
		
		private var _from:UnescapedJID;
		private var _nick:String;
		private var _color:String;
		private var _body:String; 
		private var _time:Date;
		public var local:Boolean;
		public var consecutive:Boolean;
		private var _chat:SparkChat;
		 
		public function SparkMessage(from:UnescapedJID, body:String, nick:String = null, color:String = null, time:Date = null, chat:SparkChat=null)
		{
			_from = from;
			_nick = nick;
			_color = color;
			_body = body;
			_time = time;
			_chat = chat;
		}
		
		public static function fromMessage(message:Message, chat:SparkChat, local:Boolean = false) : SparkMessage
		{
			var msg:SparkMessage = new SparkMessage(message.from.unescaped, message.body, null, null, message.time, chat);
			msg.local = local;
			return msg;
		}
		 
		public function set from(from:UnescapedJID):void {
			_from = from;
		}
		
		public function get from():UnescapedJID {
			return _from;
		}
		
		public function set nick(nick:String):void {
			_nick = nick;
		}
		
		public function get nick():String 
		{
			if(_chat && from == _chat.jid)
				return chat.displayName;
			
			if(_nick && _nick.length > 0)
				return _nick;
				
			if(local)
				return chat.myNickName;
			
			var item:RosterItemVO = RosterItemVO.get(from, false);
			if(item)
				return item.displayName;
			
			if(_chat && _chat is SparkGroupChat)
  	    		return from.resource;
			else
				return from.node;
		}
		
		public function set color(color:String):void {
			_color = color;
		}
		
		public function get color():String {
			return _color;
		}
		
		public function set body(body:String):void {
			_body = body;
		}
		
		public function get body():String {
			return _body;
		}
		
		public function set time(t:Date):void {
			_time = t;
		}
		
		public function get time():Date {
			return _time; 
		}
		
		public function set chat(chat:SparkChat):void {
			_chat = chat;
		}
		
		public function get chat():SparkChat {
			return _chat;
		}
	}
}