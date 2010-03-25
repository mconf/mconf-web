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
	import flash.xml.XMLDocument;

	public class IncomingDataEvent extends Event
	{
		
		public static var INCOMING_DATA:String = "incomingData";
		private var _data:XMLDocument;
		
		public function IncomingDataEvent()
		{
			super(IncomingDataEvent.INCOMING_DATA, false, false);
		}
		public function get data():XMLDocument
		{
			return _data;
		}
		public function set data(x:XMLDocument):void
		{
			_data = x;
		}
	}
}