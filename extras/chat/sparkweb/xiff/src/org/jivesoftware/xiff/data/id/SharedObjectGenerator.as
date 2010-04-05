/*
 * Copyright (C) 2003-2007 
 * Sean Voisen <sean@voisen.org>
 * Sean Treadway <seant@oncotype.dk>
 * Media Insites, Inc.
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
	 
package org.jivesoftware.xiff.data.id
{
	
	import org.jivesoftware.xiff.data.id.IIDGenerator;
	import flash.net.SharedObject;
	
	/**
	 * Generates an incrementing ID and saves the last value in a local shared object.
	 * Guaranteed to generate unique IDs for a single machine.
	 */
	public class SharedObjectGenerator implements IIDGenerator
	{
		private static var SO_COOKIE_NAME:String = "IIDGenerator";
	
		private var mySO:SharedObject;
	
		public function SharedObjectGenerator()
		{
			mySO = SharedObject.getLocal(SO_COOKIE_NAME);
			if (mySO.data.myCounter == undefined) {
				mySO.data.myCounter = 0;
			}
		}
	
		/**
		 * Gets the unique ID.
		 *
		 * @param prefix The ID prefix to use when generating the ID
		 * @return The generated ID
		 */
		public function getID(prefix:String):String
		{
			mySO.data.myCounter++;
	
			var id:String;
	
			if (prefix != null) {
				id = prefix + mySO.data.myCounter;
			} else {
				id = mySO.data.myCounter.toString();
			}
			return id;
		}
	}
}