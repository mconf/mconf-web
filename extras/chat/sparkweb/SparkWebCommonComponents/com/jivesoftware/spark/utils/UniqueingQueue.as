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

package com.jivesoftware.spark.utils
{
	public dynamic class UniqueingQueue extends Array
	{
		public function UniqueingQueue(contents:Array = null)
		{
			super();
			if(contents)
			{
				for each(var obj:* in contents)
					push(obj);
			}
		}
		
		private function removeDuplicates(obj:*):void
		{
			for each(var item:* in this)
			{
				if(obj == item)
					splice(indexOf(item), 1);
			}
		}
		
		AS3 override function push(...args):uint
		{
			for each(var obj:* in args)
			{
				removeDuplicates(obj);
				super.push(obj);
			}
			return length;
		}
		
		AS3 override function unshift(...args):uint
		{
			for each(var obj:* in args)
			{
				removeDuplicates(obj);
				super.unshift(obj);
			}
			return length;
		}
	}
}