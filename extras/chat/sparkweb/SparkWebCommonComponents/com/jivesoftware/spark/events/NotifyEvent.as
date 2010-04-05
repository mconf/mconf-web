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

package com.jivesoftware.spark.events
{
	import flash.events.Event;
	
	import org.jivesoftware.xiff.data.Message;

	public class NotifyEvent extends Event
	{
		public static const NEW_MESSAGE:String = "newMessage";
		
		protected var _message:Message;
		
		public function NotifyEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
		
		public function set message(inMessage:Message):void {
			_message = inMessage;
		}
		
		public function get message():Message {
			return _message;
		}
		
	}
}