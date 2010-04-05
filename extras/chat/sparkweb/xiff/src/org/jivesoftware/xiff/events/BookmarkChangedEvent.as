package org.jivesoftware.xiff.events
{
	import flash.events.Event;
	
	import org.jivesoftware.xiff.bookmark.GroupChatBookmark;
	import org.jivesoftware.xiff.bookmark.UrlBookmark;

	public class BookmarkChangedEvent extends Event
	{
		public static const GROUPCHAT_BOOKMARK_ADDED:String = "groupchat bookmark retrieved";
		public static const GROUPCHAT_BOOKMARK_REMOVED:String = "groupchat bookmark removed";
		//add url types here when needed
		
		public var groupchatBookmark:GroupChatBookmark = null;
		public var urlBookmark:UrlBookmark = null;
		
		public function BookmarkChangedEvent(type:String, bookmark:*):void {
			super(type);
			if(bookmark is GroupChatBookmark)
				groupchatBookmark = bookmark as GroupChatBookmark;
			else
				urlBookmark = bookmark as UrlBookmark;
		}
	}
}