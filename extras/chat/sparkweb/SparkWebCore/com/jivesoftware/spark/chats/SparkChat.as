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
	
	import com.jivesoftware.spark.managers.*;
	
	import flash.events.EventDispatcher;
	import flash.xml.XMLNode;
	
	import mx.collections.ArrayCollection;
	import mx.controls.*;
	import mx.events.PropertyChangeEvent;
	
	import org.jivesoftware.xiff.core.UnescapedJID;
	import org.jivesoftware.xiff.data.Message;
	import org.jivesoftware.xiff.data.im.RosterItemVO;
	import org.jivesoftware.xiff.util.*;
	
	[Bindable]
	public class SparkChat extends EventDispatcher
	{
		private var _ui:ChatUI
		protected var _jid:UnescapedJID;
		protected var _nickname:String;
		protected var windowID:String;
		
		protected var _presence:String;
		protected var _activated:Boolean;
		protected var _isReady:Boolean = false;
				
		
		
		public function SparkChat(j:UnescapedJID)
		{
			_jid = j;
		}
		
		
		
		public function get ui():ChatUI
		{
			return _ui;
		}
		
		public function set ui(view:ChatUI):void
		{
			_ui = view;
			setup(_jid);
		}
		
		public function setup(j:UnescapedJID):void
		{
			var rosterItem:RosterItemVO = RosterItemVO.get(j, true);
			
			_jid = rosterItem.jid;
			displayName = rosterItem.displayName;
			presence = rosterItem.show;
			rosterItem.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, function(evt:PropertyChangeEvent):void {
				if(evt.property == "show")
					presence = evt.newValue as String;
			});
		}
		
		//return value indicates whether the message did anything the user needs to be notified about, basically. probably less than ideal.
		public function handleMessage(msg:Message):Boolean
		{
			if(!msg.body)
			{
			    var childNode:XMLNode = msg.getNode().firstChild;
				if(!childNode || childNode.namespaceURI != 'jabber:x:event')
					return false;

				ui.isTyping = childNode.childNodes.some(
					function(node:XMLNode, index:int, arr:Array):Boolean { return node.nodeName == 'composing'; }
				);
				
				return false;			    
			}
			
			insertMessage(SparkMessage.fromMessage(msg, this));
			return true;
		}
		
		[Bindable(event="occupantsChanged")]
		public function get occupants():ArrayCollection {
			return new ArrayCollection([{nick : myNickName}, {nick : displayName}]);
		}
		
		public function get jid():UnescapedJID {
			return _jid;
		}
		
		public function set displayName(nickname:String):void {
			_nickname = nickname;
		}
		
		public function get displayName():String {
			return _nickname;
		}
		
		//the user's nickname; this is because it may vary in groupchats
		public function get myNickName():String {
			return SparkManager.me.displayName;
		}

		public function insertMessage(message:SparkMessage):void 
		{		
			ui.addMessage(message);
		}
			
		public function set presence(presence:String):void {
			_presence = presence;
		}
		
		public function get presence():String {
			return _presence;
		}
		
		public function insertSystemMessage(body:String, time:Date = null):void {
			ui.addSystemMessage(body, time);
		}
		
		//actually does the sending to the connection
		public function transmitMessage(message:SparkMessage):void {
			SparkManager.connectionManager.sendMessage(jid, message.body);
		}
		
		public function init():void 
		{
		}
		
		public function close():void {
		}
	}
}