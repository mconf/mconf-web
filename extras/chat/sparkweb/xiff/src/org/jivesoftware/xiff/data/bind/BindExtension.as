package org.jivesoftware.xiff.data.bind
{
	import flash.xml.XMLNode;
	
	import org.jivesoftware.xiff.core.EscapedJID;
	import org.jivesoftware.xiff.data.Extension;
	import org.jivesoftware.xiff.data.ExtensionClassRegistry;
	import org.jivesoftware.xiff.data.IExtension;
	import org.jivesoftware.xiff.data.ISerializable;
	import org.jivesoftware.xiff.data.XMLStanza;

	public class BindExtension extends Extension implements IExtension, ISerializable
	{
		public static var NS:String = "urn:ietf:params:xml:ns:xmpp-bind";
		public static var ELEMENT_NAME:String = "bind";
		private var _jid:EscapedJID;
		private var _resource:String;
		
		public function getNS():String
		{
			return BindExtension.NS;
		}
		
		public function getElementName():String
		{
			return BindExtension.ELEMENT_NAME;
		}
		
		public function get jid():EscapedJID
		{
			return _jid;
		}
		
		public function serialize(parent:XMLNode):Boolean
		{
			if (!exists(getNode().parentNode)) {
				var child:XMLNode = getNode().cloneNode(true);
				var resourceNode:XMLNode = new XMLNode(1, "resource");
				resourceNode.appendChild(XMLStanza.XMLFactory.createTextNode(resource ? resource : "xiff"));
				child.appendChild(resourceNode);
				parent.appendChild(child);
			}
			return true;
		}
		
		public function BindExtension( parent:XMLNode = null)
		{
			super(parent);
		}
		
		/**
	     * Registers this extension with the extension registry.  
	     */
	    public static function enable():void
	    {
	        ExtensionClassRegistry.register(BindExtension);
	    }
		
		public function deserialize(node:XMLNode):Boolean
		{
			setNode(node);
			var children:Array = node.childNodes;
			for( var i:String in children ) {
				switch( children[i].nodeName )
				{
					case "jid":
						_jid = new EscapedJID(children[i].firstChild.nodeValue);
						break;
					default:
						throw "Unknown element: " + children[i].nodeName;
				}
			}
			return true;
		}
		
		public function set resource(newResource:String):void
		{
			_resource = newResource;
		}
		
		public function get resource():String
		{
			return _resource;
		}
		
	}
}