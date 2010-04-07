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

package com.jivesoftware.spark.displayfilters
{
	import mx.utils.StringUtil;
	
	public class EmoticonFilter {
		
		private static const images:Object = {
			"(!)" : "alert",
			":)" : "happy",
        	":-)" : "happy",
        	":(" : "sad",
        	":-(" : "sad",
        	":d" : "grin", //why? because we lowercase the string first, and :D becomes :d
        	":-d" : "grin",
        	":x" : "love",
        	"(heart)" : "heart",
        	"(i)" : "info",
        	";\\" : "mischief",
        	"b-)" : "cool",
        	"]:)" : "devil",
        	":p" : "silly",
        	":-p" : "silly",
        	"&gt;:o" : "angry", //need to use &gt; due to html's requirements
        	"&gt;:-o" : "angry",
	        "X-(" : "angry",
	        ":^0" : "laugh",
	        ";)" : "wink",
	        ";-)" : "wink",
	        ":-[" : "blush", //???
	        ":8}" : "blush",
	        ":_|" : "cry",
	        ":'(" : "cry",
	        "?:|" : "confused",
	        ":0" : "shocked",
	        ":o" : "shocked",
	        ":|" : "plain",
	        "(-)" : "minus",
	        "(+)" : "plus"    
		};
		
		  /**
     * Applys the emoticon filter to a string. For example, if you wanted the
     * actual graphic for :) :<p>
     * <pre>
     * String graphic = EmoticonFilter.applyFilter(":)");
     * </pre>
     * </p>
     *
     * You would receive happy.
     * @param string the string to parse for emoticon images.
     * @return the emoticon image link.
     */
    public static function apply(string:String):String 
    {
    	//temporarily disabled
        if (true || !string || string.length == 0)
            return string;

        var buf:String = "";
        var tkn:Array = string.split(" ");
        for each(var str:String in tkn)
        {
			var found:String = "images/emoticons/" + images[StringUtil.trim(str).toLowerCase()] + ".gif";
			       
            if (found != "images/emoticons/undefined.gif")
                str = buildURL(found);

            buf += str + " ";	 
        }
        return buf;
    }
    
     /**
     * Returns an HTML image tag using the base image URL and image name.
     * @param imageName the relative url of the image to build.
     * @return the new img tag to use.
     */
    private static function buildURL(imagePath:String):String {
        return "<img border=\"0\" src=\"" + imagePath + "\">";
    }
		
	}
}
