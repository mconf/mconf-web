/*
 * Copyright (C) 2003-2007 
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
 * Lesser General Public License for more details.s
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
 *
 */
	 
package org.jivesoftware.xiff.data.auth
{
	/**
	 * A static class for SHA1 hash creation. Original ActionScript 1.0 version 
	 * by Branden Hall. Original ActionScript 2.0 translation by Ron Haberle.
	 */
	public class SHA1
	{
		private static var hex_chr:String = "0123456789abcdef";
		
		/**
		 * Takes a string and returns the hex representation of its SHA1 hash.
		 *
		 * @param str The string to use for calculating the hash
		 * @return The SHA1 hash of the string passed to the function
		 */
		public static function calcSHA1(str:String):String
		{
			var x:Array = SHA1.str2blks(str);
			var w:Array = new Array(80);
			var a:Number = 1732584193;
			var b:Number = -271733879;
			var c:Number = -1732584194;
			var d:Number = 271733878;
			var e:Number = -1009589776;
			for (var i:Number = 0; i < x.length; i += 16)
			{
				var olda:Number = a;
				var oldb:Number = b;
				var oldc:Number = c;
				var oldd:Number = d;
				var olde:Number = e;
				for (var j:Number = 0; j < 80; j++)
				{
					if (j < 16)
					{
						w[j] = x[i + j];
					}
					else
					{
						w[j] = SHA1.rol(w[j - 3] ^ w[j - 8] ^ w[j - 14] ^ w[j - 16], 1);
					}
					var t:Number = SHA1.safe_add(SHA1.safe_add(SHA1.rol(a, 5), SHA1.ft(j, b, c, d)), SHA1.safe_add(SHA1.safe_add(e, w[j]), SHA1.kt(j)));
					e = d;
					d = c;
					c = SHA1.rol(b, 30);
					b = a;
					a = t;
				}
				a = SHA1.safe_add(a, olda);
				b = SHA1.safe_add(b, oldb);
				c = SHA1.safe_add(c, oldc);
				d = SHA1.safe_add(d, oldd);
				e = SHA1.safe_add(e, olde);
			}
			return SHA1.hex(a) + SHA1.hex(b) + SHA1.hex(c) + SHA1.hex(d) + SHA1.hex(e);
		}
		
		private static function hex(num:Number):String
		{
			var str:String = "";
			for (var j:Number = 7; j >= 0; j--)
			{
				str += hex_chr.charAt((num >> (j * 4)) & 0x0F);
			}
			return str;
		}
		
		/*
		 * Convert a string to a sequence of 16-word blocks, stored as an array.
		 * Append padding bits and the length, as described in the SHA1 standard.
		 */
		private static function str2blks(str:String):Array
		{
			var nblk:Number = ((str.length + 8) >> 6) + 1;
			var blks:Array = new Array(nblk * 16);
			for (var i:Number = 0; i < nblk * 16; i++)
			{
				blks[i] = 0;
			}
			for (var j:Number = 0; j < str.length; j++)
			{
				blks[j >> 2] |= str.charCodeAt(j) << (24 - (j % 4) * 8);
			}
			blks[j >> 2] |= 0x80 << (24 - (j % 4) * 8);
			blks[nblk * 16 - 1] = str.length * 8;
			return blks;
		}
		
		/*
		 * Add integers, wrapping at 2^32. This uses 16-bit operations internally
		 * to work around bugs in some JS interpreters.
		 */
		private static function safe_add(x:Number, y:Number):Number
		{
			var lsw:Number = (x & 0xFFFF) + (y & 0xFFFF);
			var msw:Number = (x >> 16) + (y >> 16) + (lsw >> 16);
			return (msw << 16) | (lsw & 0xFFFF);
		}
		
		/*
		 * Bitwise rotate a 32-bit number to the left
		 */
		private static function rol(num:Number, cnt:Number):Number
		{
			return (num << cnt) | (num >>> (32 - cnt));
		}
		
		/*
		 * Perform the appropriate triplet combination function for the current
		 * iteration
		 */
		private static function ft(t:Number, b:Number, c:Number, d:Number):Number
		{
			if (t < 20)
			{
				return (b & c) | ((~b) & d);
			}
			if (t < 40)
			{
				return b ^ c ^ d;
			}
			if (t < 60)
			{
				return (b & c) | (b & d) | (c & d);
			}
			return b ^ c ^ d;
		}
		
		/*
		 * Determine the appropriate additive constant for the current iteration
		 */
		private static function kt(t:Number):Number
		{
			return (t < 20) ? 1518500249 : (t < 40) ? 1859775393 : (t < 60) ? -1894007588 : -899497514;
		}
	}
}