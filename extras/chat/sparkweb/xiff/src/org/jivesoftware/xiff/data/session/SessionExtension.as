package org.jivesoftware.xiff.data.session
{
	import flash.xml.XMLNode;
	
	import org.jivesoftware.xiff.data.Extension;
	import org.jivesoftware.xiff.data.ExtensionClassRegistry;
	import org.jivesoftware.xiff.data.IExtension;
	import org.jivesoftware.xiff.data.ISerializable;
	import org.jivesoftware.xiff.data.XMLStanza;

	public class SessionExtension extends Extension implements IExtension, ISerializable
	{
		public static var NS:String = "urn:ietf:params:xml:ns:xmpp-session";
		public static var ELEMENT_NAME:String = "session";
		private var jid:String;
		
		public function getNS():String
		{
			return SessionExtension.NS;
		}
		
		public function getElementName():String
		{
			return SessionExtension.ELEMENT_NAME;
		}
		
		public function getJID():String
		{
			return jid;
		}
		
		public function serialize(parent:XMLNode):Boolean
		{
			if (!exists(getNode().parentNode)) {
				var child:XMLNode = getNode().cloneNode(true);
				parent.appendChild(child);
			}
			return true;
		}
		
		public function SessionExtension( parent:XMLNode = null)
		{
			super(parent);
		}
		
		/**
	     * Registers this extension with the extension registry.  
	     */
	    public static function enable():void
	    {
	        ExtensionClassRegistry.register(SessionExtension);
	    }
		
		public function deserialize(node:XMLNode):Boolean
		{
			setNode(node);
			return true;
		}
		
	}
}