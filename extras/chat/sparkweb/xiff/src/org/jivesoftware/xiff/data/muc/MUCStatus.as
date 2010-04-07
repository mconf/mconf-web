package org.jivesoftware.xiff.data.muc
{
	import flash.xml.XMLNode;
	
	import org.jivesoftware.xiff.data.XMLStanza;
	
	public class MUCStatus
	{
		private var node:XMLNode;
		private var parent:XMLStanza
		public function MUCStatus(xmlNode:XMLNode, parentStanza:XMLStanza)
		{
			super();
			node = xmlNode ? xmlNode : new XMLNode(1, "status");
			parent = parentStanza;
		}

		/**
		 * Property used to add or retrieve a status code describing the condition that occurs.
		 */
		public function get code():Number
		{
			return node.attributes.code;
		}
		
		public function set code(newCode:Number):void
		{
			node.attributes.code = newCode.toString();
		}
		
		/**
		 * Property that contains some text with a description of a condition.
		 */
		public function get message():String
		{
			return node.firstChild.nodeValue;
		}
	
		public function set message(val:String):void
		{
			node = parent.replaceTextNode(parent.getNode(), node, "status", val);
		}
	}
}