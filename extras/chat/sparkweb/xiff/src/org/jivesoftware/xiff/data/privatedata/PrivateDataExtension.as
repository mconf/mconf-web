package org.jivesoftware.xiff.data.privatedata
{
	import flash.xml.XMLNode;
	
	import org.jivesoftware.xiff.data.ExtensionClassRegistry;
	import org.jivesoftware.xiff.data.IExtension;
	import org.jivesoftware.xiff.data.ISerializable;
	import org.jivesoftware.xiff.privatedata.IPrivatePayload;

	public class PrivateDataExtension implements IExtension, ISerializable
	{
		private var _extension:XMLNode;
		private var _payload:IPrivatePayload;
		
		public function PrivateDataExtension(privateName:String = null, privateNamespace:String = null, payload:IPrivatePayload = null):void {
			this._extension = new XMLNode(1, privateName);
			this._extension.attributes["xmlns"] = privateNamespace;
			this._payload = payload;
		}
		
		public function getNS():String
		{
			return "jabber:iq:private";
		}
		
		public function getElementName():String
		{
			return "query";
		}
		
		public function get privateName():String {
			return this._extension.nodeName;
		}
		
		public function get privateNamespace():String {
			return this._extension.attributes["xmlns"];
		}
		
		public function get payload():IPrivatePayload {
			return _payload;
		}
		
		public function serialize(parentNode:XMLNode):Boolean
		{
			var extension:XMLNode = this._extension.cloneNode(true);
			var query:XMLNode = new XMLNode(1, "query");
			query.attributes.xmlns = "jabber:iq:private";
			query.appendChild(extension);
			parentNode.appendChild(query);

			return _serializePayload(extension);
		}
		
		private function _serializePayload(parentNode:XMLNode):Boolean {
			if(_payload == null) {
				return true;
			}
			else {
				return _payload.serialize(parentNode);
			}
		}
		
		public function deserialize(node:XMLNode):Boolean
		{
			var payloadNode:XMLNode = node.firstChild;
			var ns:String = payloadNode.attributes["xmlns"];
			if(ns == null) {
				return false;
			}	
			
			this._extension = new XMLNode(1, payloadNode.nodeName);
			this._extension.attributes["xmlns"] = ns;
			
			var extClass:Class = ExtensionClassRegistry.lookup(ns);
			if(extClass == null) {
				return false;
			}
			var ext:IPrivatePayload = new extClass();
			if (ext != null && ext is IPrivatePayload) {
				ext.deserialize(payloadNode);
				this._payload = ext;
				return true;
			}
			else {
				return false;
			}
		}
		
	}
}