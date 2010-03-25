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

package com.jivesoftware.spark.managers {
	import org.jivesoftware.xiff.core.EscapedJID;
	import org.jivesoftware.xiff.core.XMPPConnection;
	import org.jivesoftware.xiff.data.IQ;
	import org.jivesoftware.xiff.data.register.RegisterExtension;
		
	
	public class AccountManager {
		
		private var _connection:XMPPConnection;
		private var _callBackFunction:Function;
		
		public function AccountManager(con:XMPPConnection):void {
			this._connection = con;
		}
		
		public function createAccount(username:String, password:String, callBackFunction:Function):void 
		{
			var iq:IQ = new IQ(new EscapedJID(_connection.server), IQ.SET_TYPE);
		    iq.callbackName = "handleRegistration";
		    iq.callbackScope = this;
			
			var reg:RegisterExtension = new RegisterExtension();
			reg.username = username;
			reg.password = password;
			iq.addExtension(reg);
			
			_callBackFunction = callBackFunction;
			
			_connection.send(iq);
		}
		
		public function handleRegistration(iq:IQ):void {
			_callBackFunction.call(this, iq);
		}
	}
}