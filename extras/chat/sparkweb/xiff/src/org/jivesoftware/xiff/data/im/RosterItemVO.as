package org.jivesoftware.xiff.data.im
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.events.PropertyChangeEvent;
	
	import org.jivesoftware.xiff.core.UnescapedJID;
	
	public class RosterItemVO extends EventDispatcher implements Contact
	{
		private static var allContacts:Object = {};
		private var _jid:UnescapedJID
		private var _displayName:String;
		private var _groups:Array = [];
		private var _askType:String;
		private var _subscribeType:String;
		private var _status:String;
		private var _show:String;
		private var _priority:Number;
		private var _online:Boolean = false;
		
		public function RosterItemVO(newJID:UnescapedJID):void 
		{
			jid = newJID;
		}
		
		public static function get(jid:UnescapedJID, create:Boolean):RosterItemVO
		{
			var bareJID:String = jid.bareJID;
			var item:RosterItemVO = allContacts[bareJID];
			if(!item && create)
				allContacts[bareJID] = item = new RosterItemVO(new UnescapedJID(bareJID));
			return item;
		}
		
		public function set uid(i:String):void
		{
			
		}
		
		public function get uid():String
		{
			return _jid.toString();
		}
		
		public function set subscribeType(newSub:String):void
		{
			var oldSub:String = subscribeType;
			_subscribeType = newSub;
			PropertyChangeEvent.createUpdateEvent(this, "subscribeType", oldSub, subscribeType);
			dispatchEvent(new Event("changeSubscription"));
		}
		
		[Bindable]
		public function get subscribeType():String
		{
			return _subscribeType;
		}
		
		public function set priority(newPriority:Number):void
		{
			var oldPriority:Number = priority;
			_priority = newPriority;
			PropertyChangeEvent.createUpdateEvent(this, "priority", oldPriority, priority);
		}
		
		[Bindable]
		public function get priority():Number
		{
			return _priority;
		}
		
		public function set askType(aT:String):void
		{
			var oldasktype:String = askType;
			var oldPending:Boolean = pending;
			_askType = aT;
			PropertyChangeEvent.createUpdateEvent(this, "askType", oldasktype, askType);
			PropertyChangeEvent.createUpdateEvent(this, "pending", oldPending, pending);
			
			dispatchEvent(new Event("changeAskType"));
		}
		
		[Bindable]
		public function get askType():String
		{
			return _askType;	
		}
		
		public function set status(newStatus:String):void
		{
			var oldStatus:String = status;
			_status = newStatus;
			PropertyChangeEvent.createUpdateEvent(this, "status", oldStatus, status);
		}
		
		[Bindable]
		public function get status():String
		{
			if(!online)
				return "Offline";
			return _status ? _status : "Available";
		}
		
		public function set online(newState:Boolean):void
		{
			if(newState == online)
				return;
			var oldOnline:Boolean = online;
			_online = newState;
			PropertyChangeEvent.createUpdateEvent(this, "online", oldOnline, online);
		}
		
		[Bindable]
		public function get online():Boolean
		{
			return _online;
		}
		
		public function set show(newShow:String):void
		{
			var oldShow:String = show;
			_show = newShow;
			PropertyChangeEvent.createUpdateEvent(this, "show", oldShow, show);
		}
		
		[Bindable]
		public function get show():String
		{
			return _show;
		}
		
		public function set jid(j:UnescapedJID):void
		{
			var oldjid:UnescapedJID = _jid;
			_jid = j;
			//if we aren't using a custom display name, then settings the jid updates the display name
			if(!_displayName)
				dispatchEvent(new Event("changeDisplayName"));
				
			PropertyChangeEvent.createUpdateEvent(this, "jid", oldjid, j);
		}
		
		[Bindable]
		public function get jid():UnescapedJID
		{
			return _jid;
		}
		
		public function set displayName(name:String):void
		{
			var olddisplayname:String = displayName;
			_displayName = name;
			PropertyChangeEvent.createUpdateEvent(this, "displayName", olddisplayname, displayName);
			dispatchEvent(new Event("changeDisplayName"));
		}
		
		[Bindable(event=changeDisplayName)]
		public function get displayName():String
		{
			return _displayName ? _displayName : _jid.node;
		}
		
		[Bindable(event=changeAskType)]
		[Bindable(event=changeSubscription)]
		public function get pending():Boolean {
			return askType == RosterExtension.ASK_TYPE_SUBSCRIBE && (subscribeType == RosterExtension.SUBSCRIBE_TYPE_NONE || subscribeType == RosterExtension.SUBSCRIBE_TYPE_FROM);
		}
	    
	    public override function toString():String
	    {
	    	return jid.toString();
	    }
	}
}