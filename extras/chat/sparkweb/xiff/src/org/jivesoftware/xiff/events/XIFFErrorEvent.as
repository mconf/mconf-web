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
	
	import org.jivesoftware.xiff.data.Extension;

	public class XIFFErrorEvent extends Event
	{
		public static var XIFF_ERROR:String = "error";
		private var _errorCondition:String;
		private var _errorMessage:String;
		private var _errorType:String;
		private var _errorCode:Number;
		private var _errorExt:Extension;
		
		public function XIFFErrorEvent()
		{
			super(XIFFErrorEvent.XIFF_ERROR, false, false);
		}
		public function set errorCondition(s:String):void
		{
			_errorCondition = s;
		}
		public function get errorCondition():String
		{
			return _errorCondition;
		}
		public function set errorMessage(s:String):void
		{
			_errorMessage = s;
		}
		public function get errorMessage():String
		{
			return _errorMessage;
		}
		public function set errorType(s:String):void
		{
			_errorType = s;
		}
		public function get errorType():String
		{
			return _errorType;
		}
		public function set errorCode(n:Number):void
		{
			_errorCode = n;
		}
		public function get errorCode():Number
		{
			return _errorCode;
		}
		public function set errorExt(ext:Extension):void
		{
			_errorExt = ext;
		}
		public function get errorExt():Extension
		{
			return _errorExt;
		}
	}
}