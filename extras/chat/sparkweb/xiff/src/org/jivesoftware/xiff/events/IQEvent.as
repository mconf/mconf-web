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
	import org.jivesoftware.xiff.data.IExtension;
	import org.jivesoftware.xiff.data.IQ;
	
	public class IQEvent extends Event
	{
		private var _data:IExtension;
		private var _iq:IQ;
		
		public function IQEvent(type:String)
		{
			super(type, false, false);
		}
		public function get data():IExtension
		{
			return _data;
		}
		public function set data(x:IExtension):void
		{
			_data = x;
		}
		
		public function get iq():IQ
		{
			return _iq;
		}
		public function set iq(i:IQ):void
		{
			_iq = i;
		}
	}
}