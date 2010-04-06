package org.jivesoftware.xiff.data.events
{
import org.jivesoftware.xiff.data.IExtension;
	import org.jivesoftware.xiff.data.ISerializable;
	import flash.xml.XMLNode;
	
	public class MessageEventExtension implements IExtension, ISerializable {
		
		public function getNS():String{
			return "jabber:x:event";
		}
		
		public function getElementName():String {
			return "x";
		}
		
		/**
		 * Called when the library need to retrieve the state of the instance.  If the instance manages its own state, then the state should be copied into the XMLNode passed.  If the instance also implements INodeProxy, then the parent should be verified against the parent XMLNode passed to determine if the serialization is in the same namespace.
		 *
		 * @param parentNode (XMLNode) The container of the XML.
		 * @returns On success, return true.
		 */
		public function serialize( parentNode:XMLNode ):Boolean {
			var xmlNode:XMLNode = new XMLNode(1, 'x');
			xmlNode.attributes.xmlns = "jabber:x:event";
			var childNode:XMLNode = new XMLNode(1, "composing");
			xmlNode.appendChild(childNode);
			parentNode.appendChild(xmlNode);			
			return true;
		}
	
		/**
		 * Called when data is retrieved from the XMLSocket, use this method to extract any state into internal state.
		 * @param node (XMLNode) The node that should be used as the data container.
		 * @returns On success, return true.
		 */
		public function deserialize( node:XMLNode ):Boolean {
			return true;
		}
		
		
		
	}
}