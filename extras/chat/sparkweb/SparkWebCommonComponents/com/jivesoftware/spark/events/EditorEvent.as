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

	public class EditorEvent extends Event
	{
		public static const MESSAGE_CREATED:String = "messageCreated";
		public static const COMPLETE_WORD:String = "completeWord";
		public static const RESET_COMPLETION:String = "resetCompletion";
		
		private var _message:String;
		
		public function EditorEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
		
		public function set message(message:String):void {
			this._message = message;
		}
		
		public function get message():String {
			return this._message;
		}
	}
}