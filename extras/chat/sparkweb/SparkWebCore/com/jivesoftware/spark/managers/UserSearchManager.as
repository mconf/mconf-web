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

package com.jivesoftware.spark.managers
{
	
	import flash.display.DisplayObjectContainer;
	
	import mx.core.Application;
	import mx.managers.PopUpManager;
	
	import org.jivesoftware.xiff.core.XMPPConnection;
	
	/**
	 * Manages the list of known search services.
	 */
	public class UserSearchManager extends AbstractSearchManager
	{
		[Bindable]
		private static var _sharedInstance:UserSearchManager;
		
		public static function get sharedInstance():UserSearchManager
		{
			if(!_sharedInstance)
				_sharedInstance = new UserSearchManager(SparkManager.connectionManager.connection);
			return _sharedInstance;
		}
		
		// Sets up the search manager and initializes.
		public function UserSearchManager(connection:XMPPConnection):void
		{
			_connection = connection;
		}
		
		protected override function get identityType():String
		{
			return "user";
		}
	}	
}
