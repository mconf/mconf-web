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

package com.jivesoftware.spark
{
	public class ScrollWheelManager
	{
		public function ScrollWheelManager()
		{
		}
		
		private static var regFun:Function = null;
		
		public static function set registrationFunction(fun:Function):void
		{
			regFun = fun;
		}
		
		/**
		 * Registers an element to receive mouse wheel events; hacking around Flash's lack of support
		 */
		public static function registerForScrollEvents(obj:Object) : void {
			if(null != regFun)
				regFun(obj);
		}

	}
}