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
	
	
	public class URLFilter	{
		
		public static function apply(string:String):String {
			if (!string || string.length == 0)
        	    return string;
	
			var buf:String = "";
	        var tkn:Array = string.split(" ");
	        for(var i:uint = 0; i < tkn.length; i++)
	        {
	        	 var token:String = tkn[i].toLowerCase();
	        	 
				 if (token.indexOf("http://") == 0 ||
				 	 token.indexOf("ftp://") == 0 ||
                    token.indexOf("https://") == 0) 
                {
                	buf += buildURL(tkn[i]);
                }
                else if(token.indexOf("www") == 0)
                {
                 	var newURL:String = "http://" + tkn[i];
                 	buf += buildURL(newURL);
                }
                else
                 	buf += tkn[i];
				 
				 buf += " ";
	        }
	        return buf;
			
		}
	
   	  	private static function buildURL(url:String):String {
        	return "<a href='"+url+"' target='_blank'>"+url+"</a>";
     	}
	}
}