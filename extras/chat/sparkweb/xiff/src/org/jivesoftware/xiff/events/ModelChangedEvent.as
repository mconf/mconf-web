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

	public class ModelChangedEvent extends Event
	{
		public static var MODEL_CHANGED:String = "modelChanged";
		private var _firstItem:String;
		private var _lastItem:String;
		private var _removedIDs:String;
		private var _fieldName:String;
		public function ModelChangedEvent()
		{
			super(ModelChangedEvent.MODEL_CHANGED, false, false);
		}
		public function set firstItem(s:String):void
		{
			_firstItem = s;
		}
		public function get firstItem():String
		{
			return _firstItem;
		}
		public function set lastItem(s:String):void
		{
			_lastItem = s;
		}
		public function get lastItem():String
		{
			return _lastItem;
		}
		public function set removedIDs(s:String):void
		{
			_removedIDs = s;
		}
		public function get removedIDs():String
		{
			return _removedIDs;
		}
		public function set fieldName(s:String):void
		{
			_fieldName = s;
		}
		public function get fieldName():String
		{
			return _fieldName;
		}
	}
}
					