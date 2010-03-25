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
	 
package org.jivesoftware.xiff.events
{
	import flash.events.Event;
	
	import org.jivesoftware.xiff.data.Message;

	public class RoomEvent extends Event
	{
		public static const SUBJECT_CHANGE:String = "subjectChange";
		public static const GROUP_MESSAGE:String = "groupMessage";
		public static const PRIVATE_MESSAGE:String = "privateMessage";
		public static const ROOM_JOIN:String = "roomJoin";
		public static const ROOM_LEAVE:String = "roomLeave";
		public static const ROOM_DESTROYED:String = "roomDestroyed";
		public static const AFFILIATIONS:String = "affiliations";
		public static const ADMIN_ERROR:String = "adminError";
		public static const PASSWORD_ERROR:String = "passwordError";
		public static const REGISTRATION_REQ_ERROR:String = "registrationReqError";
		public static const BANNED_ERROR:String = "bannedError";
		public static const MAX_USERS_ERROR:String = "maxUsersError";
		public static const LOCKED_ERROR:String = "lockedError";
		public static const USER_JOIN:String = "userJoin";
		public static const USER_DEPARTURE:String = "userDeparture";
		public static const USER_KICKED:String = "userKicked";
		public static const USER_BANNED:String = "userBanned";
		public static const NICK_CONFLICT:String = "nickConflict";
		public static const CONFIGURE_ROOM:String = "configureForm";
		public static const DECLINED:String = "declined";
		
		private var _subject:String;
		private var _data:*;
		private var _errorCondition:String;
		private var _errorMessage:String;
		private var _errorType:String;
		private var _errorCode:Number;
		private var _nickname:String;
		private var _from:String;
		private var _reason:String;
		
		public function RoomEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		public function set subject(s:String) : void
		{
			_subject = s;
		}
		public function get subject() : String
		{
			return _subject;
		}
		public function set data(s:*) : void
		{
			_data = s;
		}
		public function get data() : *
		{
			return _data;
		}
		public function set errorCondition(s:String) : void
		{
			_errorCondition = s;
		}
		public function get errorCondition() : String
		{
			return _errorCondition;
		}
		public function set errorMessage(s:String) : void
		{
			_errorMessage = s;
		}
		public function get errorMessage() : String
		{
			return _errorMessage;
		}
		public function set errorType(s:String) : void
		{
			_errorType = s;
		}
		public function get errorType() : String
		{
			return _errorType;
		}
		public function set errorCode(s:Number) : void
		{
			_errorCode = s;
		}
		public function get errorCode() : Number
		{
			return _errorCode;
		}
		public function set nickname(s:String) : void
		{
			_nickname = s;
		}
		public function get nickname() : String
		{
			return _nickname;
		}
		public function set from(s:String) : void
		{
			_from = s;
		}
		public function get from() : String
		{
			return _from;
		}
		public function set reason(s:String) : void
		{
			_reason = s;
		}
		public function get reason() : String
		{
			return _reason;
		}
	}
}