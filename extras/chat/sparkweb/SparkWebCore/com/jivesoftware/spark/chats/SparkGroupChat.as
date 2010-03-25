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
	import com.jivesoftware.spark.events.ChatEvent;
	import com.jivesoftware.spark.managers.ChatManager;
	import com.jivesoftware.spark.managers.Localizator;
	import com.jivesoftware.spark.managers.MUCManager;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	
	import org.jivesoftware.xiff.conference.Room;
	import org.jivesoftware.xiff.core.UnescapedJID;
	import org.jivesoftware.xiff.data.muc.MUCItem;
	import org.jivesoftware.xiff.data.muc.MUCUserExtension;
	import org.jivesoftware.xiff.events.RoomEvent;
	
	public class SparkGroupChat extends SparkChat
	{
  	    protected var _room:Room;
  	    private var roomPassword:String = null;
  	    private var recentlyChangedNicks:Object = null;
  	    
  	    public function SparkGroupChat(j:UnescapedJID)
  	    {
  	    	super(j);
  	    }
  	    
  	    public override function setup(j:UnescapedJID):void
  	    {
  	    	room = MUCManager.manager.getRoom(j);
  	    	displayName = room.roomJID.toString();
  	    	if (roomPassword != null)
  	    		room.password = roomPassword;

  	    	// Handle possible errors on joining the room
  	    	room.addEventListener(RoomEvent.PASSWORD_ERROR, handlePasswordError);
  	    	room.addEventListener(RoomEvent.REGISTRATION_REQ_ERROR, handleRegistrationReqError);
  	    	room.addEventListener(RoomEvent.BANNED_ERROR, handleBannedError);
  	    	room.addEventListener(RoomEvent.NICK_CONFLICT, handleNickConflict);
  	    	room.addEventListener(RoomEvent.MAX_USERS_ERROR, handleMaxUsersError);
  	    	room.addEventListener(RoomEvent.LOCKED_ERROR, handleLockedError);
  	    	
  	    	if(!room.join()) {
  	    		dispatchEvent(new Event("joinFailed"));
  	    		return;
  	    	}
  	    	
  	    	room.addEventListener(CollectionEvent.COLLECTION_CHANGE, function(evt:CollectionEvent):void {
  	    		dispatchEvent(new Event("occupantsChanged"));
  	    		removeErrorEventListeners();
  	    	});
  	    	
  	    	// Listen to common room events
  	    	room.addEventListener(RoomEvent.USER_JOIN, handleUserJoin);
  	    	room.addEventListener(RoomEvent.USER_DEPARTURE, handleUserDeparture);
  	    	room.addEventListener(RoomEvent.USER_KICKED, handleUserKicked);
  	    	room.addEventListener(RoomEvent.USER_BANNED, handleUserBanned);

  	    }
  	    
  	    public override function get jid():UnescapedJID
  	    {
  	    	return room.roomJID;
  	    }
  	    
  	    [Bindable]
  	    public function get room():Room
  	    {
  	    	return _room;
  	    }
  	    
  	    public override function close():void
  	    {
  	    	removeCommonEventListeners();

  	    	super.close();
  	    	room.leave();
  	    }
  	    
  	    //the user's nickname; this is because it may vary in groupchats
		public override function get myNickName():String {
			return room.nickname;
		}
  	    
  	    public override function insertMessage(message:SparkMessage):void
  	    {
  	    	if(room.isThisUser(message.from) && message.time == null)
				return;
			super.insertMessage(message);
  	    }
  	    
  	    public override function transmitMessage(message:SparkMessage):void {
  	    	room.sendMessage(message.body);
		}
  	    
  	    public function set room(r:Room):void
  	    {
  	    	_room = r;
  	    }
  	    
  	    public function set password(pw:String):void
  	    {
  	    	roomPassword = pw;
  	    }
  	    
  	    public override function set displayName(name:String):void
  	    {
  	    	if(name.indexOf('@') > -1)
				name = name.split('@')[0];
			super.displayName = name;
  	    }
  	    
  	    public override function get occupants():ArrayCollection
  	    {
  	    	return room;
  	    }
  	    
  	    private function error(type:String, close:Boolean = true):void
  	    {
  	    	var errEvt:ChatEvent = new ChatEvent(ChatEvent.CHAT_ERROR);
  	    	errEvt.error = type;
  	    	errEvt.chat = this;
  	    	ChatManager.sharedInstance.dispatchEvent(errEvt);
  	    	ChatManager.sharedInstance.closeChat(this);
  	    	removeErrorEventListeners();
  	    }
  	    
  	    public function handlePasswordError(event:RoomEvent):void
  	    {
  	    	error(ChatEvent.PASSWORD_ERROR);
  	    }
  	    
  	    public function handleRegistrationReqError(event:RoomEvent):void
  	    {
  	    	error(ChatEvent.REGISTRATION_REQUIRED_ERROR);
  	    }
  	    
  	    public function handleBannedError(event:RoomEvent):void
  	    {
  	    	error(ChatEvent.BANNED_ERROR);
  	    }
  	    
  	    public function handleNickConflict(event:RoomEvent):void
  	    {
  	    	error(ChatEvent.NICK_CONFLICT_ERROR);
  	    }
  	    
  	    public function handleMaxUsersError(event:RoomEvent):void
  	    {
  	    	error(ChatEvent.MAX_USERS_ERROR);
  	    }
  	    
  	    public function handleLockedError(event:RoomEvent):void
  	    {
  	    	error(ChatEvent.ROOM_LOCKED_ERROR);
  	    }
  	    
  	    private function removeErrorEventListeners():void
  	    {
      		room.removeEventListener(RoomEvent.PASSWORD_ERROR, handlePasswordError);
      		room.removeEventListener(RoomEvent.REGISTRATION_REQ_ERROR, handleRegistrationReqError);
      		room.removeEventListener(RoomEvent.BANNED_ERROR, handleBannedError);
      		room.removeEventListener(RoomEvent.NICK_CONFLICT, handleNickConflict);
      		room.removeEventListener(RoomEvent.MAX_USERS_ERROR, handleMaxUsersError);
      		room.removeEventListener(RoomEvent.LOCKED_ERROR, handleLockedError);
  	    }
  	    
  	    public function handleUserJoin(event:RoomEvent):void
  	    {
  	    	// Is this join a result of a recent nick change?
  	    	if (recentlyChangedNicks != null) {
  	    		var nickChange:Array = recentlyChangedNicks[event.nickname];
  	    		if (nickChange != null) {
  	    			insertSystemMessage(Localizator.getTextWithParams('muc.notification.nick.change', nickChange));
  	    			delete recentlyChangedNicks[event.nickname];
  	    			return;
  	    		}
  	    	}
  	    	
  	    	if (event.nickname != myNickName)
  	    		insertSystemMessage(Localizator.getTextWithParams('muc.notification.join', [event.nickname]));
  	    }
  	    
  	    public function handleUserDeparture(event:RoomEvent):void
  	    {
  	    	// Was this a nick change?
  			var userExt:MUCUserExtension = event.data.getAllExtensionsByNS(MUCUserExtension.NS)[0];
			if (userExt && userExt.hasStatusCode(303)) {
				if (recentlyChangedNicks == null)
					recentlyChangedNicks = new Object();
				var userExtItem:MUCItem = userExt.getAllItems()[0];
				recentlyChangedNicks[userExtItem.nick] = [event.nickname, userExtItem.nick];
				return;
			}

  	    	insertSystemMessage(Localizator.getTextWithParams('muc.notification.departure', [event.nickname]));
  	    }
  	    
  	    public function handleUserKicked(event:RoomEvent):void
  	    {
  	    	insertSystemMessage(Localizator.getTextWithParams('muc.notification.kicked', [event.nickname]));
  	    }
  	    
  	    public function handleUserBanned(event:RoomEvent):void
  	    {
  	    	insertSystemMessage(Localizator.getTextWithParams('muc.notification.banned', [event.nickname]));
  	    }
  	    
  	    private function removeCommonEventListeners():void
  	    {
  	    	room.removeEventListener(RoomEvent.USER_JOIN, handleUserJoin);
  	    	room.removeEventListener(RoomEvent.USER_DEPARTURE, handleUserDeparture);
  	    	room.removeEventListener(RoomEvent.USER_KICKED, handleUserKicked);
  	    	room.removeEventListener(RoomEvent.USER_BANNED, handleUserBanned);
  	    }
	}
}