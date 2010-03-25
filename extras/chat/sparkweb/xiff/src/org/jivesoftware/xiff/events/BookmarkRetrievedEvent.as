package org.jivesoftware.xiff.events
{
	import flash.events.Event;

	public class BookmarkRetrievedEvent extends Event
	{
		public static var BOOKMARK_RETRIEVED:String = "bookmark retrieved";
		
		public function BookmarkRetrievedEvent():void {
			super(BOOKMARK_RETRIEVED);
		}
	}
}