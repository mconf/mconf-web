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
	public class StringUtils {
    
    /**
     * Unescapes the String by converting HTML escape sequences back into normal
     * <p/>
     * characters.
     *
     * @param string the string to unescape.
     * @return the string with appropriate characters unescaped.
     */

   public static function unescapeHTML(string:String):String {
    	string = string.replace(/[\r\n]/g, "<br>");
    	string = string.replace(/\\\\/g, "\\")
    	string = string.replace(/&lt;/g, "<");
		string = string.replace(/&gt;/g, ">"); 
 		string = string.replace(/&quot;/g, '"');
		string = string.replace(/&amp;/g, "&");

        return string;

    }

    /**
     * Escapes the String by converting html to escaped string.
     * <p/>
     * characters.
     *
     * @param string the string to escape.
     * @return the string with appropriate characters escaped.
     */

	//if we use the literal regexp notation, flex gets confused and thinks the quote starts a string
	private static var quoteregex:RegExp = new RegExp('"', "g");
	
    public static function escapeHTML(string:String):String {
    	string = string.replace(/<br>/g, "\n");
    	string = string.replace(/&/g, "&amp;");
    	string = string.replace(/</g, "&lt;");
     	string = string.replace(/>/g, "&gt;");
   		string = string.replace(quoteregex, "&quot;");
   	//	string = string.replace(/\\/g, "\\\\");

        return string;

    }
    
    private static var alphabet:String = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXY';
    
    public static function randomString(length:int):String {
    	var result:String = "";
    	while(length--) {
    		result += alphabet.charAt(Math.floor(Math.random() * alphabet.length));
    	}
    	return result;
    }
	}
}