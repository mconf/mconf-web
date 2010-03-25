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

// sho.util.ArrayUtil v. 0.6

// This code is released under the creative commons license. If you use this code, 
// give me attribution if you feel like it. :-)
//
// This code has not been extensively tested, and may have lots and lots of bugs;
// use at your own risk.

// v. 0.6 -- no major changes 
// v. 0.5 -- first public release

package sho.util {
	import sho.core.Range;
	
	public class ArrayUtil 
	{
		private static const ZERO_CHAR : Number = "0".charCodeAt(0);
		
		public static function find(a: Array, item: Object) : int
		{
			for (var i: int = 0; i < a.length; i++)
			{
				if (a[i] == item)
					return i;
			}
			
			return -1;
		}
		
		public static function remove(a: Array, item: Object) : Object
		{
			var result : Object = null;
			var i : int = find(a, item);
			if (i != -1)
			{
				result = a[i];
				a.splice(i, 1);
			}
			return result;
		}
		
		// Adds an element to an array, which is assumed to already be sorted.
		// If multiple elements have the same value, the new item is added last.
		//
		// The compare function takes two objects and returns a negative number 
		// if the first object is "less than" the second, 0 if they are considered 
		// equal, and a positive number otherwise.
		//
		// The compare function will always be passed the objects from the array
		// as its first parameter, and the item to search for as its second
		// parameter.
		public static function addSorted(a: Array, item: Object, compareFunc: Function = null) : void
		{
			var lo : int = 0;
			var hi : int = a.length-1; 
			var mid : int; 
			
			var loVal : * = a[lo];
			var hiVal : * = a[hi];
			var midVal : *;

			if (compareFunc == null)
				compareFunc = defaultCompare;
				
			// If the array has no entries, or if this is less than all the existing 
			// values, it goes at the beginning.
			if (hi == lo || compareFunc(loVal, item) > 0)
			{
				a.unshift(item);
				return;
			}
			
			// If this is greater to or equal to the last value, it goes
			// at the end.
			else if (compareFunc(hiVal, item) <= 0)
			{
				a.push(item);
				return;
			}
			
			// Otherwise, find the correct position.
			while (hi-lo > 1)
			{
				mid = (hi-lo)/2 + lo;
				midVal = a[mid];
				
				var compare: int = compareFunc(midVal, item);
				if (compare > 0)
				{
					// Midpoint is greater than our object. Take the lower half.
					hi = mid;
					hiVal = midVal;
				}
				else
				{
					// Less than or equal to our object. Take the upper half.
					lo = mid;
					loVal = midVal;
				}
			}
			
			// At this point, hi and lo should bracket the correct position.
			a.splice(hi, 0, item);
		}

		public static function binarySearchOn(array: Array, item: Object, field: String, compareFunc: Function = null) : int
		{
			if (compareFunc == null)
				compareFunc = defaultCompare;

			var actualCompareFunc : Function = function(a:*, b:*) : int 
			{ 
				var aVal:* = a[field];
				return (compareFunc(aVal, b));
			}
			
			return binarySearch(array, item, actualCompareFunc);
		}
		
		public static function binarySearch(array: Array, item: Object, compareFunc: Function = null) : int
		{
			if (array == null)
				return -1;

			if (compareFunc == null)
				compareFunc = defaultCompare

			var lo : int = 0;
			var hi : int = array.length-1;
			var mid : int;
			var foundLo : int = -1;
			var foundHi : int = -1;
			var compare : int;

			while (hi >= lo)
			{
				mid = (hi+lo)/2;
	
				compare = compareFunc(array[mid], item);
				if (compare < 0)
				{
					lo = mid+1;
				}
				else if (compare > 0)
				{
					hi = mid-1;
				}
				else
				{
					return mid;
				}
			}
			
			return -1;
		}

		public static function binarySearchForRange(array: Array, item: Object, compareFunc: Function = null) : Range
		{
			if (array == null)
				return null;

			if (compareFunc == null)
				compareFunc = defaultCompare;

			// binary search to find initial match.
			var lo : int = 0;
			var hi : int = array.length-1;
			var mid : int;
			var foundLo : int = -1;
			var foundHi : int = -1;
			var compare : int;

			while (hi >= lo)
			{
				mid = (hi+lo)/2;
	
				compare = compareFunc(array[mid], item);
				if (compare < 0)
				{
					lo = mid+1;
				}
				else if (compare > 0)
				{
					hi = mid-1;
				}
				else
				{
					foundLo = foundHi = mid;
					break;
				}
			}
			
			// No match was found.
			if (foundLo == -1)
				return null;
				
			// Continue binary search to find bounds of match.
	
			var savedLo : int = lo;
			var savedHi : int = hi;
			
			// Look for lower bound of match range.
			
			// First, check to see if lo is a match. I believe 
			// the only way that lo can be a match is the case 
			// where lo == 0.
			if (compareFunc(array[lo], item) == 0)
			{
				foundLo = lo;
			}
			else
			{
				// Binary search for the lower bound of match range.
				
				// In this pass, the invariant is that the hi part of the
				// range will always be a match, while the lo part will
				// always be outside the match. The search terminates
				// when hi and lo are right next to one another.
	
				hi = (hi+lo)/2;
				
				while (hi-lo > 1)
				{
					mid = (hi+lo)/2;
	
					compare = compareFunc(array[mid], item);
					if (compare < 0)
					{
						// Mid is not a match. Move lo up and repeat.
						lo = mid;
					}
					else if (compare > 0)
					{
						// Should never happen. Assert?
					}
					else
					{
						// Mid is a match. Move the hi down to mid and repeat.
						hi = mid;
					}
				}
				
				foundLo = hi;
			}
			
			// Restore lo and hi, and do the opposite to find top of range.
			lo = savedLo;
			hi = savedHi;
			
			if (compareFunc(array[hi], item) == 0)
			{
				foundHi = hi;
			}
			else
			{
				lo = (hi+lo)/2;
				
				while (hi-lo > 1)
				{
					mid = (hi+lo)/2;
	
					compare = compareFunc(array[mid], item);
					if (compare < 0)
					{
						// assert?
					}
					else if (compare > 0)
					{
						hi = mid;
					}
					else
					{
						lo = mid;
					}
				}
				
				// The high part of the search range is the lower bound.
				foundHi = lo;
			}
			
			return new Range(foundLo, foundHi);
		}
						
		public static function defaultCompare(a:*, b:*) : int 
		{ 
			if (a==b)
				return 0;
			else
			{
				if (a < b)
					return -1;
				else
					return 1;
			}
		}
		
		public static function compareStrings(a: String, b: String) : int
		{
			return doCompareString(a, b, false);
		}
		
		public static function compareNoCase(a: String, b: String) : int
		{
			return doCompareNoCase(a, b, false);
		}
		
		// The alphanumeric sort is an attempt to sort combinations of letters
		// and numbers the way a human would. (see doCompareAlphaNumeric() 
		// for details.

		public static function compareAlphaNumeric(a: String, b: String) : int
		{
			return doCompareAlphaNumeric(a, b);
		}
		
		public static function compareNumeric(a: String, b: String) : int
		{
			var aNum: Number = a as Number;
			var bNum: Number = b as Number;
			
			if (aNum < bNum)
				return -1;
			else if (aNum > bNum)
				return 1;
			return 0;
		}
			
		public static function prefixCompare(s: String, prefix: String) : int
		{
			return doCompareString(s, prefix, true);
		}
		
		public static function prefixCompareNoCase(s: String, prefix: String) : int
		{
			return doCompareNoCase(s, prefix, true);
		}
		
		private static function doCompareString(s: String, prefix: String, isPrefixSort : Boolean) : int
		{
			if (prefix == null || s == null)
				return 0;
	
			var limit : int = Math.min(prefix.length, s.length);
			
			var a : int;
			var b : int;
			
			for (var i : int = 0; i < limit; i++)
			{
				a = s.charCodeAt(i);
				b = prefix.charCodeAt(i);
				
				if (a < b)
					return -1;
				else if (a > b)
					return 1;
			}

			// If the string is shorter than the prefix, return -1.	
			if (s.length < prefix.length)
				return -1;
	
			// If this is not a prefix sort, and if the string is longer than the prefix, return 1.
			if (!isPrefixSort && s.length > prefix.length)
				return 1;
			
			// Otherwise, consider these to be equal.
			return 0;
		}
			
		private static function doCompareNoCase(s: String, prefix: String, isPrefixSort: Boolean) : int
		{
			if (prefix == null || s == null)
				return 0;
	
			var limit : int = Math.min(prefix.length, s.length);
			
			var a : String;
			var b : String;
			
			for (var i : int = 0; i < limit; i++)
			{
				a = s.charAt(i).toLowerCase();
				b = prefix.charAt(i).toLowerCase();
				
				if (a < b)
					return -1;
				else if (a > b)
					return 1;
			}
			
			// If the string is shorter than the prefix, return -1.	
			if (s.length < prefix.length)
				return -1;
	
			// If this is not a prefix sort, and if the string is longer than the prefix, return 1.
			if (!isPrefixSort && s.length > prefix.length)
				return 1;
			
			// Otherwise, consider these to be equal.
			return 0;
		}
	
		// The alphanumeric sort is an attempt to sort combinations of letters
		// and numbers the way a human would.
		//
		// Rules:
		// 1) Sequences of digits are combined into a single number that
		//    occupies one logical "character" of space.
		// 2) Numbers sort in the standard way when compared against other
		//    numbers. When compared against characters, any number is
		//    considered to sort before any character.
		// 3) Letters are sorted without regard to case.
		//
		//
		// Example sort:
		//		Version_1
		//		Version_2
		//		Version_10                // 10 sorts after 2
		//		Version_10_revision_1
		//		Version_10_revision_2
		//		Version_10_revision_12
		//		Version_11
		//		Version_100
		//
		// Note that this algorithm will fail when using floating point numbers:
		//      1.2
		//      1.12   // This will be treated as "one point twelve"
		//
		// Of course "fail" is a relative term, in that this is the correct
		// heuristic for certain cases, such as version numbers.
		//
		//      Version 1.0.89
		//      Version 1.0.105
		//

		private static function doCompareAlphaNumeric(aString: String, bString: String) : int
		{
			if (bString == null || aString == null)
				return 0;
	
			var a : String;
			var b : String;
			var aNum : Number;
			var bNum : Number;
			var aLength: Number = aString.length;
			var bLength: Number = bString.length;
			
			var i : Number = 0;
			var j : Number = 0;
			
			while (i < aLength && j < bLength)
			{
				var aCode : Number = aString.charCodeAt(i);
				var bCode : Number = bString.charCodeAt(j);
				var aIsDigit : Boolean = isDigit(aCode);
				var bIsDigit : Boolean = isDigit(bCode);
				
				if (aIsDigit && bIsDigit)
				{
					// Two numbers -- compare numerically
					aNum = 0;
					bNum = 0;
				
					while (i < aLength && isDigit(aCode))
					{
						aNum *= 10;
						aNum += aCode - ZERO_CHAR;
						i++;
						if (i < aLength)
							aCode = aString.charCodeAt(i);
					}
					
					while (j < bLength && isDigit(bCode))
					{
						bNum *= 10;
						bNum += bCode - ZERO_CHAR;
						j++;
						if (j < aLength)
							bCode = bString.charCodeAt(j);
					}
					
					if (aNum < bNum)
						return -1;
					else if (aNum > bNum)
						return 1;
				}
				else if (aIsDigit && !bIsDigit)
				{
					return 1;
				}
				else if (!aIsDigit && bIsDigit)
				{
					return -1;
				}
				else
				{
					// Compare alphabetically.
					a = aString.charAt(i++).toLowerCase();
					b = bString.charAt(j++).toLowerCase();
					
					if (a < b)
						return -1;
					else if (a > b)
						return 1;
					
				}
			}
			
			// If the aString is shorter than bString, return -1.	
			if (i == aLength && j < bLength)
				return -1;
	
			// If aString is longer than bString, return 1.
			if (i < aLength && j == bLength)
				return 1;
			
			// Otherwise, consider these to be equal.
			return 0;
		}
		
		private static function isDigit(charCode : int) : Boolean
		{
			var val : int = charCode - ZERO_CHAR;
			return val < 10 && val >= 0;
		}
		
		public static function isSorted(a: Array, compare: Function) : Boolean
		{
			if (a.length < 2)
				return true;
				
			var limit : int = a.length;
			var last : * = a[0];
			var current : *;
						
			for (var i : int =1; i < limit; i++)
			{
				current = a[i];
				if (compare(current, last) < 0)
					return false;
				last = current;
			}
			
			return true;
		}
	}
}