package org.jivesoftware.xiff.core
{
	public class AbstractJID
	{
		//TODO: this doesn't actually validate properly in some cases; need separate nodePrep, etc...
		protected static var jidNodeValidator:RegExp = /^([\x29\x23-\x25\x28-\x2E\x30-\x39\x3B\x3D\x3F\x41-\x7E\xA0 \u1680\u202F\u205F\u3000\u2000-\u2009\u200A-\u200B\u06DD \u070F\u180E\u200C-\u200D\u2028-\u2029\u0080-\u009F \u2060-\u2063\u206A-\u206F\uFFF9-\uFFFC\uE000-\uF8FF\uFDD0-\uFDEF \uFFFE-\uFFFF\uD800-\uDFFF\uFFF9-\uFFFD\u2FF0-\u2FFB]{1,1023})/;
		protected var _node:String = "";
		protected var _domain:String = "";
		protected var _resource:String = "";
		
		public function AbstractJID(inJID:String, validate:Boolean=false):void {
			if(validate)
			{
    			if(!jidNodeValidator.test(inJID) || inJID.indexOf(" ") > -1) 
    			{
        			trace("Invalid JID: %s", inJID);
        			throw "Invalid JID";
    			}
   			}
   			var separatorIndex:int = inJID.lastIndexOf("@");
   			var slashIndex:int = inJID.lastIndexOf("/");
   			if(slashIndex >= 0) 
   				_resource = inJID.substring(slashIndex + 1);
   			_domain = inJID.substring(separatorIndex + 1, slashIndex >= 0 ? slashIndex : inJID.length);
   			if(separatorIndex >= 1)
   				_node = inJID.substring(0, separatorIndex);
		}
		
		//if we use the literal regexp notation, flex gets confused and thinks the quote starts a string
		private static var quoteregex:RegExp = new RegExp('"', "g");
		private static var quoteregex2:RegExp = new RegExp("'", "g");
		
		public static function escapedNode(n:String):String
		{
			if( n && (
				n.indexOf("@") >= 0 ||
				n.indexOf(" ") >= 0 ||
				n.indexOf("\\")>= 0 ||
				n.indexOf("/") >= 0 ||
				n.indexOf("&") >= 0 ||
				n.indexOf("'") >= 0 ||
				n.indexOf('"') >= 0 ||
				n.indexOf(":") >= 0 ||
				n.indexOf("<") >= 0 ||
				n.indexOf(">") >= 0))
			{
				n = n.replace(/\\/g, "\\5c");
				n = n.replace(/@/g, "\\40");
	    		n = n.replace(/ /g, "\\20");
	    		n = n.replace(/&/g, "\\26");
	     		n = n.replace(/>/g, "\\3e");
	     		n = n.replace(/</g, "\\3c");
	     		n = n.replace(/:/g, "\\3a");
	     		n = n.replace(/\//g, "\\2f");
	   			n = n.replace(quoteregex, "\\22");
	   			n = n.replace(quoteregex2, "\\27");
	   		}
   			return n;
		}
		
		public static function unescapedNode(n:String):String
		{
			if( n && (
				n.indexOf("\\40") >= 0 ||
				n.indexOf("\\20") >= 0 ||
				n.indexOf("\\26")>= 0 ||
				n.indexOf("\\3e") >= 0 ||
				n.indexOf("\\3c") >= 0 ||
				n.indexOf("\\5c") >= 0 ||
				n.indexOf('\\3a') >= 0 ||
				n.indexOf("\\2f") >= 0 ||
				n.indexOf("\\22") >= 0 ||
				n.indexOf("\\27") >= 0) )
			{
				n = n.replace(/\40/g, "@");
	    		n = n.replace(/\20/g, " ");
	    		n = n.replace(/\26/g, "&");
	     		n = n.replace(/\3e/g, ">");
	     		n = n.replace(/\3c/g, "<");
	     		n = n.replace(/\3a/g, ":");
	     		n = n.replace(/\2f/g, "/");
	   			n = n.replace(quoteregex, '"');
	   			n = n.replace(quoteregex2, "'");
	   			n = n.replace(/\5c/g, "\\");
	  		}
   			return n;
		}
		
    	public function toString():String 
    	{
    		var j:String = "";
    		if(node)
    			j += node + "@";
    		j += domain;
    		if(resource)
    			j += "/" + resource;
    		
			return j;
    	}
    	
    	public function get bareJID():String 
    	{
    		var str:String = toString();
    		var slashIndex:int = str.lastIndexOf("/");
    		if(slashIndex > 0)
    			str = str.substring(0, slashIndex);
        	return str;
    	}
    	
    	public function get resource():String 
    	{
        	if(_resource.length > 0)
        		return _resource;
        	return null;
    	}
    	
    	public function get node():String 
    	{
        	if(_node.length > 0)
        		return _node;
            return null;
    	}
    	
    	public function get domain():String 
    	{
        	return _domain;
    	}
	}
}