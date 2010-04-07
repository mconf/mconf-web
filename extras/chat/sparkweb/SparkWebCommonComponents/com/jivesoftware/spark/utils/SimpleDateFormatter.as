package com.jivesoftware.spark.utils
{
	public class SimpleDateFormatter
	{
		/**
		 * SimpleDateFormatter.as
		 * 
		 * An Actionscript 2 implementation of the Java SimpleDateFormat class.
		 * This code was directly adapted from Matt Kruse's Javascript class
		 * implementation, and is used/distributed with Matt's permission.
		 * 
		 * Please report all bugs to Daniel Wabyick (dwabyick@fluid.com).
		 * 
		 * @author Daniel Wabyick (Actionscript 2 port) 
		 * 					   http://www.fluid.com
		 * @author Matt Kruse ( Javascript implementation)
		 * 					   http://www.JavascriptToolbox.com
		 * 
		 * The following notice is maintained from Matt Kruse's 
		 * original Javascript code. 
		 * 
		 * NOTICE: You may use this code for any purpose, commercial or
		 * private, without any further permission from the author. You may
		 * remove this notice from your final code if you wish, however it is
		 * appreciated by the author if at least my web site address is kept.
		 *
		 
		 * HISTORY
		 * ------------------------------------------------------------------
		 * Oct 05, 2005 Wrapped into a static AS2 class - DWABYICK/FLUID
		 * May 17, 2003: Fixed bug in parseDate() for dates <1970
		 * March 11, 2003: Added parseDate() function
		 * March 11, 2003: Added "NNN" formatting option. Doesn't match up
		 *                 perfectly with SimpleDateFormat formats, but 
		 *                 backwards-compatability was required.
		 *
		 * USAGE
		 * ------------------------------------------------------------------
		 * These functions use the same 'format' strings as the 
		 * java.text.SimpleDateFormat class, with minor exceptions.
		 * The format string consists of the following abbreviations:
		 * 
		 * Field        | Full Form          | Short Form
		 * -------------+--------------------+-----------------------
		 * Year         | yyyy (4 digits)    | yy (2 digits), y (2 or 4 digits)
		 * Month        | MMM (name or abbr.)| MM (2 digits), M (1 or 2 digits)
		 *              | NNN (abbr.)        |
		 * Day of Month | dd (2 digits)      | d (1 or 2 digits)
		 * Day of Week  | EE (name)          | E (abbr)
		 * Hour (1-12)  | hh (2 digits)      | h (1 or 2 digits)
		 * Hour (0-23)  | HH (2 digits)      | H (1 or 2 digits)
		 * Hour (0-11)  | KK (2 digits)      | K (1 or 2 digits)
		 * Hour (1-24)  | kk (2 digits)      | k (1 or 2 digits)
		 * Minute       | mm (2 digits)      | m (1 or 2 digits)
		 * Second       | ss (2 digits)      | s (1 or 2 digits)
		 * AM/PM        | a                  |
		 *
		 * NOTE THE DIFFERENCE BETWEEN MM and mm! Month=MM, not mm!
		 * Examples:
		 *  "MMM d, y" matches: January 01, 2000
		 *                      Dec 1, 1900
		 *                      Nov 20, 00
		 *  "M/d/yy"   matches: 01/20/00
		 *                      9/2/00
		 *  "MMM dd, yyyy hh:mm:ssa" matches: "January 01, 2000 12:30:45AM"
		 */
		
		public static var MONTH_NAMES:Array=new Array('January','February','March','April','May','June','July','August','September','October','November','December','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');
		public static var DAY_NAMES:Array=new Array('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sun','Mon','Tue','Wed','Thu','Fri','Sat');
		public static function LZ(x:Number) : String {
			var res:String = x.toString();
			if(x >= 0 && x <= 9)
				res = "0" + res;
			return res;
		}
		
		
		
		/**
		 * Convert a date object into a string using the given format.
		 * @param date The date value to convert.
		 * @param format The format of the date object. (e.g. "yyyy-MM-dd")
		 * @return The string value of the date.
		 */
		public static function formatDate( date:Date, format:String ):String 
		{
			format=format+"";
			var result:String="";
			var i_format:int=0;
			var c:String="";
			var token:String="";
			var y:Number=date.getFullYear();
			var M:Number=date.getMonth()+1;
			var d:Number=date.getDate();
			var E:Number=date.getDay();
			var H:Number=date.getHours();
			var m:Number=date.getMinutes();
			var s:Number=date.getSeconds();
			// var yyyy,yy,MMM,MM,dd,hh,h,mm,ss,ampm,HH,H,KK,K,kk,k;
			// Convert real date parts into formatted versions
			var value:Object=new Object();
			if (String(y).length < 4) {y=(y-0+1900);}
			value["y"]=""+y;
			value["yyyy"]=y;
			value["yy"]=String(y).substring(2,4);
			value["M"]=M;
			value["MM"]=LZ(M);
			value["MMM"]=MONTH_NAMES[M-1];
			value["NNN"]=MONTH_NAMES[M+11];
			value["d"]=d;
			value["dd"]=LZ(d);
			value["E"]=DAY_NAMES[E+7];
			value["EE"]=DAY_NAMES[E];
			value["H"]=H;
			value["HH"]=LZ(H);
			if (H==0){value["h"]=12;}
			else if (H>12){value["h"]=H-12;}
			else {value["h"]=H;}
			value["hh"]=LZ(value["h"]);
			if (H>11){value["K"]=H-12;} else {value["K"]=H;}
			value["k"]=H+1;
			value["KK"]=LZ(value["K"]);
			value["kk"]=LZ(value["k"]);
			if (H > 11) { value["a"]="PM"; }
			else { value["a"]="AM"; }
			value["m"]=m;
			value["mm"]=LZ(m);
			value["s"]=s;
			value["ss"]=LZ(s);
			while (i_format < format.length) 
			{
				c=format.charAt(i_format);
				token="";
				while ((format.charAt(i_format)==c) && (i_format < format.length)) 
				{
					token += format.charAt(i_format++);
				}
				if (value[token] != null)
				{ 
					result=result + value[token]; 
				}
				else { result=result + token; }
			}
			return result;
		}
		
		/**
		 * Determine if the a given string value is a date in the given format.
		 * @param A string value representing a date.
		 * @param format The format of this date. (e.g. "yyyy-MM-dd")
		 * @return true if date string matches format of format string and
		 * is a valid date. Else returns false.
		 */
		public static function isDate( val:String, format:String ) : Boolean
		{
			var date:Date=getDateFromFormat( val,format );
			if ( date==null ) 
			{
				 return false; 
			}
			return true;
		}
		
		/**
		 *   Compare two date strings to see which is greater.
		 *   @param date1 A string representing the first date value. 
		 *   @param dateformat1 The format of the first date. (e.g. "yyyy-MM-dd")
		 *   @param date2 A string representing the second date value.
		 *   @param dateformat2 The format of the second date.(e.g. "yyyy-MM-dd")
		 *   @return  1 if date1 >date2; 0 if date2 > date; -1 if either date is an invalid format. 
		 */
		public static function compareDates( date1:String, dateformat1:String, date2:String, dateformat2:String ):Number
		{
			var d1:Date=getDateFromFormat(date1,dateformat1);
			var d2:Date=getDateFromFormat(date2,dateformat2);
			if (d1==null || d2==null) 
			{
				return -1;
			}
			else if (d1 > d2) 
			{
				return 1;
			}
			return 0;
		}
		
		/**
		 * Get a date using the given format. If it does not match, it returns 0.
		 * @param val The string value to convert to a date
		 * @param format The format of the date object.
		 * @return The date in the given format, or null if the value doesn't match the given format.
		 */
		public static function getDateFromFormat( val:String, format:String ) : Date {
			val=val+"";
			format=format+"";
			var i_val:int=0;
			var i_format:int=0;
			var c:String="";
			var token:String="";
			var token2:String="";
			var x:int;
			var y:int;
			var now:Date=new Date();
			var year:Number=now.getFullYear();
			var month:Number=now.getMonth()+1;
			var date:int=1;
			var hh:Number=now.getHours();
			var mm:Number=now.getMinutes();
			var ss:Number=now.getSeconds();
			var ampm:String="";
			var i:int=0;
			
			while (i_format < format.length) 
			{
				// Get next token from format string
				c=format.charAt(i_format);
				token="";
				while ((format.charAt(i_format)==c) && (i_format < format.length)) 
				{
					token += format.charAt(i_format++);
				}
				// Extract contents of value based on format token
				if (token=="yyyy" || token=="yy" || token=="y") 
				{
					if (token=="yyyy") { x=4;y=4; }
					if (token=="yy")   { x=2;y=2; }
					if (token=="y")    { x=2;y=4; }
					year=_getInt(val,i_val,x,y);
					i_val += String(year).length;
					if (String(year).length==2) 
					{
						if (year > 70) { year=1900+(year-0); }
						else { year=2000+(year-0); }
					}
				}
				else if (token=="MMM"||token=="NNN")
				{
					month=0;
					for (i=0; i<MONTH_NAMES.length; i++) 
					{
						var month_name:String=MONTH_NAMES[i];
						if (val.substring(i_val,i_val+month_name.length).toLowerCase()==month_name.toLowerCase())
						{
							if (token=="MMM"||(token=="NNN"&&i>11)) 
							{
								month=i+1;
								if (month>12) { month -= 12; }
								i_val += month_name.length;
								break;
							}
						}
					}
					if ((month < 1)||(month>12)){return null;}
				}
				else if (token=="EE"||token=="E")
				{
					for (i=0; i<DAY_NAMES.length; i++) 
					{
						var day_name:String=DAY_NAMES[i];
						if (val.substring(i_val,i_val+day_name.length).toLowerCase()==day_name.toLowerCase()) 
						{
							i_val += day_name.length;
							break;
						}
					}
				}
				else if (token=="MM"||token=="M") 
				{
					month=_getInt(val,i_val,token.length,2);
					if((month<1)||(month>12)){return null;}
					i_val+=String(month).length;
					}
				else if (token=="dd"||token=="d") 
				{
					date=_getInt(val,i_val,token.length,2);
					if((date<1)||(date>31)){return null;}
					i_val+=String(date).length;
					}
				else if (token=="hh"||token=="h") 
				{
					hh=_getInt(val,i_val,token.length,2);
					if((hh<1)||(hh>12)){return null;}
					i_val+=String(hh).length;
					}
				else if (token=="HH"||token=="H") 
				{
					hh=_getInt(val,i_val,token.length,2);
					if((hh<0)||(hh>23)){return null;}
					i_val+=String(hh).length;
				}
				else if (token=="KK"||token=="K") 
				{
					hh=_getInt(val,i_val,token.length,2);
					if((hh<0)||(hh>11)){return null;}
					i_val+=String(hh).length;
				}
				else if (token=="kk"||token=="k") 
				{
					hh=_getInt(val,i_val,token.length,2);
					if((hh<1)||(hh>24)){return null;}
					i_val+=String(hh).length;hh--;
				}
				else if (token=="mm"||token=="m") 
				{
					mm=_getInt(val,i_val,token.length,2);
					if((mm<0)||(mm>59)){return null;}
					i_val+=String(mm).length;
				}
				else if (token=="ss"||token=="s") 
				{
					ss=_getInt(val,i_val,token.length,2);
					if((ss<0)||(ss>59)){return null;}
					i_val+=String(ss).length;
				}
				else if (token=="a") 
				{
					if (val.substring(i_val,i_val+2).toLowerCase()=="am") {ampm="AM";}
					else if (val.substring(i_val,i_val+2).toLowerCase()=="pm") {ampm="PM";}
					else {return null;}
					i_val+=2;
				}
				else 
				{
					if (val.substring(i_val,i_val+token.length)!=token) {return null;}
					else {i_val+=token.length;}
				}
			}
			// If there are any trailing characters left in the value, it doesn't match
			if (i_val != val.length) { return null; }
			// Is date valid for month?
			if (month==2) 
			{
				// Check for leap year
				if ( ( (year%4==0)&&(year%100 != 0) ) || (year%400==0) ) 
				{ // leap year
					if (date > 29){ return null; }
				}
				else { if (date > 28) { return null; } }
			}
			if ((month==4)||(month==6)||(month==9)||(month==11)) 
			{
				if (date > 30) { return null; }
			}
			// Correct hours value
			if (hh<12 && ampm=="PM") { hh=hh-0+12; }
			else if (hh>11 && ampm=="AM") { hh-=12; }
			var newdate:Date = new Date(year,month-1,date,hh,mm,ss);
			return newdate;
		}
		
		
			
		/**
		 * @return True if the value is an integer; false otherwise.
		 */
		private static function _isInteger(val:String) : Boolean 
		{
			var digits:String="1234567890";
			for (var i:int=0; i < val.length; i++) 
			{
				if (digits.indexOf(val.charAt(i))==-1) 
				{ 
					return false; 
				}
			}
			return true;
		}
		
	 
		private static function _getInt(str:String,i:int,minlength:int,maxlength:int) : Number 
		{
			for (var x:int=maxlength; x>=minlength; x--) 
			{
				var token:String=str.substring(i,i+x);
				if (token.length < minlength) 
				{
					return NaN; 
				}
				if (_isInteger(token)) 
				{ 
					return Number(token); 
				}
			}
			return NaN;
		}
	}
}
