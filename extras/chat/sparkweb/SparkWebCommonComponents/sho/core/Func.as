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

package sho.core {
	import sho.core.LoopResult;
	import mx.collections.*;
	
	public class Func {
		public static function apply(array: Array, func: Function) : void
		{
			for each (var elem: Object in array)
			{
				var result : LoopResult = func(elem);
				if (result == LoopResult.STOP)
					return;
			}
		}
		
		public static function map(array: Array, func: Function) : Array
		{
			if (array == null)
				return null;

			if (func == null)
				return array.concat();

			var length : int = array.length;
			var result : Array = new Array(length);
			
			for (var i : int = 0; i < length; i++)
			{
				result[i] = func(array[i]);
			}
			
			return result;
		}
		
		public static function mapCollection(collection: ICollectionView, func: Function) : Array
		{
			if (collection == null)
				return null;

			var iterator : IViewCursor = collection.createCursor();
			
			var result : Array = new Array();
			var i : int = 0;
			
			if (iterator.current)
			{
				do
				{
					// Add the item to the array.
					result.push( func(iterator.current) );
				} while (iterator.moveNext());
			}
	
			return result;
		}
		
		public static function combine(func1: Function, func2: Function) : Function
		{
			return function(param: *) : * { return func1(func2(param)); }
		}

		public static function combine1of2(func1: Function, func2: Function) : Function
		{
			return function(p1: *, p2: *) : * { return func1(func2(p1), p2); }
		}
		
		public static function combine2of2(func1: Function, func2: Function) : Function
		{
			return function(p1: *, p2: *) : * { return func1(p1, func2(p2)); }
		}
	}
}