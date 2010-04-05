package org.jivesoftware.xiff.bookmark
{
	import flash.xml.XMLNode;
	
	import org.jivesoftware.xiff.core.UnescapedJID;
	import org.jivesoftware.xiff.data.ISerializable;
	import org.jivesoftware.xiff.privatedata.IPrivatePayload;

	public class BookmarkPrivatePayload implements IPrivatePayload {
		
		private var _groupChatBookmarks:Array = [];
		private var _urlBookmarks:Array = new Array();
		private var _others:Array = new Array();
		
		public function BookmarkPrivatePayload(groupChatBookmarks:Array = null, urlBookmarks:Array = null):void {
			if(groupChatBookmarks) {
				for each(var bookmark:GroupChatBookmark in groupChatBookmarks) {
					if(_groupChatBookmarks.every(function(testGroupChatBookmark:GroupChatBookmark, index:int, array:Array):Boolean { return testGroupChatBookmark.jid != bookmark.jid; }))
						_groupChatBookmarks.push(bookmark);
				}
			}
			if(urlBookmarks) {
				for each(var urlBookmark:UrlBookmark in urlBookmarks) {
					if(_urlBookmarks.every(function(testURLBookmark:UrlBookmark, index:int, array:Array):Boolean { return testURLBookmark.url != urlBookmark.url; }))
						_urlBookmarks.push(urlBookmark);
				}
			}
		}
		
		public function getNS():String {
			return "storage:bookmarks";
		}
		
		public function getElementName():String {
			return "storage";
		}
		
		public function get groupChatBookmarks():Array {
			return _groupChatBookmarks.slice();
		}
		
		public function get urlBookmarks():Array {
			return _urlBookmarks.slice();
		}
		
		//removes the bookmark from the list, and returns it
		public function removeGroupChatBookmark(jid:UnescapedJID):GroupChatBookmark {
			var removedItem:GroupChatBookmark = null;
			var newBookmarks:Array = [];
			for each(var bookmark:GroupChatBookmark in _groupChatBookmarks) {
				if (!bookmark.jid.unescaped.equals(jid, false))
					newBookmarks.push(bookmark);
				else
					removedItem = bookmark;			
			}
			_groupChatBookmarks = newBookmarks;
			return removedItem;
		}
		
		public function serialize(parentNode:XMLNode):Boolean {
			var node:XMLNode = new XMLNode(1, getElementName());
			node.attributes.xmlns = getNS();
			var serializer:Function = function(element:ISerializable, index:int, arr:Array):void {
				element.serialize(parentNode);
			};
			_groupChatBookmarks.forEach(serializer);
			_urlBookmarks.forEach(serializer);
			return true;
		}
		
		public function deserialize(bookmarks:XMLNode):Boolean 
		{
			for each(var child:XMLNode in bookmarks.childNodes) 
			{
				if(child.nodeName == "conference") 
				{
					var groupChatBookmark:GroupChatBookmark = new GroupChatBookmark();
					groupChatBookmark.deserialize(child);
					//don't add it if it's a duplicate
					if(_groupChatBookmarks.every(function(testGroupChatBookmark:GroupChatBookmark, index:int, array:Array):Boolean { return testGroupChatBookmark.jid != groupChatBookmark.jid; }))
						_groupChatBookmarks.push(groupChatBookmark);
				}
				else if(child.nodeName == "url") 
				{
					var urlBookmark:UrlBookmark = new UrlBookmark();
					urlBookmark.deserialize(child);
					//don't add it if it's a duplicate
					if(_urlBookmarks.every(function(testURLBookmark:UrlBookmark, index:int, array:Array):Boolean { return testURLBookmark.url != urlBookmark.url; }))
						_urlBookmarks.push(urlBookmark);
				}
				else {
					_others.push(child);
				}
			}
			return true;
		}
		
	}
}