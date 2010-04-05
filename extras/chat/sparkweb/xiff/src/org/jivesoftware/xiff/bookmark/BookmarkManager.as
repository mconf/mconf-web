package org.jivesoftware.xiff.bookmark
{
	import flash.events.EventDispatcher;
	
	import org.jivesoftware.xiff.core.UnescapedJID;
	import org.jivesoftware.xiff.data.ExtensionClassRegistry;
	import org.jivesoftware.xiff.data.ISerializable;
	import org.jivesoftware.xiff.data.XMPPStanza;
	import org.jivesoftware.xiff.data.privatedata.PrivateDataExtension;
	import org.jivesoftware.xiff.events.BookmarkChangedEvent;
	import org.jivesoftware.xiff.events.BookmarkRetrievedEvent;
	import org.jivesoftware.xiff.privatedata.PrivateDataManager;
	import org.jivesoftware.xiff.util.Callback;

	[Event("GroupChatBookmarkChanged")]
	
	public class BookmarkManager extends EventDispatcher
	{
		private static var bookmarkManagerConstructed:Boolean = bookmarkManagerStaticConstructor();
		
		private static function bookmarkManagerStaticConstructor():Boolean
		{	
			ExtensionClassRegistry.register( BookmarkPrivatePayload );
			return true;
		}
		
		private var _privateDataManager:PrivateDataManager;
		private var _bookmarks:BookmarkPrivatePayload;
		
		public function BookmarkManager(privateDataManager:PrivateDataManager):void {
			this._privateDataManager = privateDataManager;
		}
		
		public function fetchBookmarks():void {
			if(!this._bookmarks) {
				this._privateDataManager.getPrivateData("storage", "storage:bookmarks", new Callback(this, this["_processBookmarks"]));
			}
			else {
				dispatchEvent(new BookmarkRetrievedEvent());
			}
		}
		
		public function addGroupChatBookmark(serverBookmark:GroupChatBookmark):void {
			if(!this._bookmarks) {
				this._privateDataManager.getPrivateData("storage", "storage:bookmarks", new Callback(this, this["_processBookmarksAdd"], serverBookmark));
			}
			else {
				this._addBookmark(serverBookmark);
			}
		}
		
		public function isGroupChatBookmarked(jid:UnescapedJID):Boolean {
			for each (var bookmark:GroupChatBookmark in _bookmarks.groupChatBookmarks) {
				if (bookmark.jid.unescaped.equals(jid, false)) {
					return true;
				}
			}
			return false;
		}
		
		public function getGroupChatBookmark(jid:UnescapedJID):GroupChatBookmark {
			for each (var bookmark:GroupChatBookmark in _bookmarks.groupChatBookmarks) {
				if (bookmark.jid.unescaped.equals(jid, false)) {
					return bookmark;
				}
			}	
			return null;		
		}
		
		public function removeGroupChatBookmark(jid:UnescapedJID):void {
			if(!this._bookmarks) {
				this._privateDataManager.getPrivateData("storage", "storage:bookmarks", new Callback(this, this["_processBookmarksRemove"], jid));
			}
			else {
				this._removeBookmark(jid);				
			}
		}
		
		public function setAutoJoin(jid:UnescapedJID, state:Boolean):void {
			if(!this._bookmarks) {
				this._privateDataManager.getPrivateData("storage", "storage:bookmarks", new Callback(this, this["_processBookmarksSetAuto"], jid, state));
			}		
			else {
				this._setAutoJoin(jid, state);
			}	
		}
		
		public function get bookmarks():BookmarkPrivatePayload {
			return _bookmarks;
		}
		
		private function _processBookmarks(bookmarksIq:XMPPStanza):void {
			var privateData:PrivateDataExtension = bookmarksIq.getAllExtensionsByNS("jabber:iq:private")[0];
			_bookmarks = BookmarkPrivatePayload(privateData.payload);
			dispatchEvent(new BookmarkRetrievedEvent());
		}
		
		private function _processBookmarksAdd(bookmark:ISerializable, bookmarksIq:XMPPStanza):void {
			this._processBookmarks(bookmarksIq);
			this._addBookmark(bookmark);
		}
		
		private function _processBookmarksRemove(jid:UnescapedJID, bookmarksIq:XMPPStanza):void {
			this._processBookmarks(bookmarksIq);
			this._removeBookmark(jid);
		}
		
		private function _processBookmarksSetAuto(jid:UnescapedJID, state:Boolean, bookmarksIq:XMPPStanza):void {
			this._processBookmarks(bookmarksIq);
			this._setAutoJoin(jid, state);
		}
		
		private function _addBookmark(bookmark:ISerializable):void 
		{
			var groupChats:Array = _bookmarks.groupChatBookmarks;
			var urls:Array = _bookmarks.urlBookmarks;
			
			if(bookmark is GroupChatBookmark) {
				groupChats.push(bookmark);
			}
			else if(bookmark is UrlBookmark) {
				urls.push(bookmark);
			}
			
			var payload:BookmarkPrivatePayload = new BookmarkPrivatePayload(groupChats, urls);
			_privateDataManager.setPrivateData("storage", "storage:bookmarks", payload);
			_bookmarks = payload;
			dispatchEvent(new BookmarkChangedEvent(BookmarkChangedEvent.GROUPCHAT_BOOKMARK_ADDED, bookmark));
		}
		
		private function _removeBookmark(jid:UnescapedJID):void {
			var removedBookmark:GroupChatBookmark = _bookmarks.removeGroupChatBookmark(jid);
			this._updateBookmarks();
			dispatchEvent(new BookmarkChangedEvent(BookmarkChangedEvent.GROUPCHAT_BOOKMARK_REMOVED, removedBookmark));		
		}
		
		private function _setAutoJoin(jid:UnescapedJID, state:Boolean):void {
			for each (var bookmark:GroupChatBookmark in _bookmarks.groupChatBookmarks) {
				if (bookmark.jid.unescaped.equals(jid, false)) {
					bookmark.autoJoin = state;
				}
			}	
			this._updateBookmarks();						
		}
		
		private function _updateBookmarks():void {
			var groupChats:Array = _bookmarks.groupChatBookmarks;
			var urls:Array = _bookmarks.urlBookmarks;
			
			var payload:BookmarkPrivatePayload = new BookmarkPrivatePayload(groupChats, urls);
			_privateDataManager.setPrivateData("storage", "storage:bookmarks", payload);			
		}
	}
}