package org.jivesoftware.xiff.data.im
{
	import mx.core.IPropertyChangeNotifier;
	
	import org.jivesoftware.xiff.core.UnescapedJID;
	
	public interface Contact extends IPropertyChangeNotifier
	{
		function get jid():UnescapedJID;
		function set jid(newJID:UnescapedJID):void;
		
		function get displayName():String;
		function set displayName(name:String):void;
		
		function get show():String;
		function set show(newShow:String):void;
		
		function get online():Boolean;
		function set online(newOnline:Boolean):void;
	}
}