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
	import mx.resources.ResourceBundle;
	import mx.resources.ResourceManager; 
    
    public class Localizator
    {
        protected static var sharedInstance:Localizator;
		
		[ResourceBundle("en")]
		private var rb_eng:ResourceBundle;

        public function Localizator ()
        {
        	ResourceManager.getInstance().addResourceBundle(rb_eng);
        }
        
        public static function get instance() : Localizator 
        {
            if( !sharedInstance )
                sharedInstance = new Localizator();
            
            return sharedInstance;
        }
        
        public static function getText( key:String ) : String 
        {
        	return Localizator.instance.getText(key);
        }
        
        [Bindable(event="langChange")]
        public static function getTextWithParams( key:String, paramaters:Array ) : String
        {
        	//FIXME: when we add more languages, this will need to change
        	return ResourceManager.getInstance().getString("en", key, paramaters);
        }

        [Bindable(event="langChange")]
        public function getText( key:String ) : String 
        {
        	//FIXME: when we add more languages, this will need to change
            return ResourceManager.getInstance().getString("en", key);
        }
    }
}
