package org.jivesoftware.xiff.data.search{
	
	import org.jivesoftware.xiff.data.XMLStanza;
	import org.jivesoftware.xiff.data.ISerializable;
	import flash.xml.XMLNode;
	
	/**
	 * This class is used by the SearchExtension for internal representation of
	 * information pertaining to items matching the search query.
	 *
	 * @author Daniel Henninger
	 * @since 2.0.0
	 * @availability Flash Player 7
	 * @toc-path Extensions/Search
	 * @toc-sort 1/2
	 */
	public class SearchItem extends XMLStanza implements ISerializable
	{
		public static var ELEMENT:String = "item";
	
		private var myFields:Object;
	
		public function SearchItem(parent:XMLNode=null)
		{
			super();
			myFields = new Object();
	
			getNode().nodeName = ELEMENT;
	
			if (exists(parent)) {
				parent.appendChild(getNode());
			}
		}
	
		public function serialize(parent:XMLNode):Boolean
		{
			if (parent != getNode().parentNode) {
				parent.appendChild(getNode().cloneNode(true));
			}
	
			return true;
		}
	
		public function deserialize(node:XMLNode):Boolean
		{
			setNode(node);
	
			var children:Array = node.childNodes;
			for( var i:String in children ) {
				myFields[children[i].nodeName.toLowerCase()] = children[i];
			}
			return true;
		}

		public function getField(name:String):String
		{
			if (myFields[name] != null && myFields[name].firstChild != null) {
				return myFields[name].firstChild.nodeValue;
			}
			return null;
		}
	
		public function setField(name:String, val:String):void
		{
			myFields[name] = replaceTextNode(getNode(), myFields[name], name, val);
		}
	
		public function get jid():String
		{
			return getNode().attributes.jid;
		}
	
		public function set jid(val:String):void
		{
			getNode().attributes.jid = val;
		}
		
		public function get username():String { return getField("jid"); }
		public function set username(val:String):void { setField("jid", val); }
	
		public function get nick():String { return getField("nick"); }
		public function set nick(val:String):void { setField("nick", val); }
	
		public function get first():String { return getField("first"); }
		public function set first(val:String):void { setField("first", val); }
	
		public function get last():String { return getField("last"); }
		public function set last(val:String):void { setField("last", val); }
	
		public function get email():String { return getField("email"); }
		public function set email(val:String):void { setField("email", val); }
		
		public function get name():String { return getField("name"); }
		public function set name(val:String):void { setField("name", val); }
	}
}