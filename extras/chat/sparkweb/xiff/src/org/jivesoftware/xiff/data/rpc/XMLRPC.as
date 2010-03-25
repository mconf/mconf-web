package org.jivesoftware.xiff.data.rpc{
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;
	
	/*
	 * Copyright (C) 2003-2007 
	 * Sean Voisen <sean@voisen.org>
	 * Sean Treadway <seant@oncotype.dk>
	 * Media Insites, Inc.
	 *
	 * This library is free software; you can redistribute it and/or
	 * modify it under the terms of the GNU Lesser General Public
	 * License as published by the Free Software Foundation; either
	 * version 2.1 of the License, or (at your option) any later version.
	 * 
	 * This library is distributed in the hope that it will be useful,
	 * but WITHOUT ANY WARRANTY; without even the implied warranty of
	 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	 * Lesser General Public License for more details.
	 * 
	 * You should have received a copy of the GNU Lesser General Public
	 * License along with this library; if not, write to the Free Software
	 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
	 *
	 */
	
	/**
	 * Implements client side XML marshalling of methods and parameters into XMLRPC.
	 * For more information on RPC over XMPP, see <a href="http://www.jabber.org/jeps/jep-0009.html">
	 * http://www.jabber.org/jeps/jep-0009.html</a>.
	 *
	 * @author Sean Treadway
	 * @since 2.0.0
	 * @availability Flash Player 7
	 * @toc-path Extensions/RPC
	 * @toc-sort 1/2
	 */
	public class XMLRPC
	{
		private static var XMLFactory:XMLDocument = new XMLDocument();
	
		/**
		 * Extract and marshall the XML-RPC response to Flash types.
		 *
		 * @param xml The XML containing the message response
		 * @return Mixed object of either an array of results from the method call or a fault.
		 * If the result is a fault, "result.isFault" will evaulate as true.
		 * @availability Flash Player 7
		 */
		public static function fromXML(xml:XMLNode):Array
		{
			var result:Array;
			var response:XMLNode = findNode("methodResponse", xml);
	
			if (response.firstChild.nodeName == "fault") {
				// methodResponse/fault/value/struct
				result = extractValue(response.firstChild.firstChild.firstChild);
				result.isFault = true;
			} else {
				result = new Array();
				var params:XMLNode = findNode("params", response);
				if (params != null) {
					for (var param_idx:int=0; param_idx < params.childNodes.length; param_idx++) {
						var param:Array = params.childNodes[param_idx].firstChild;
	
						for (var type_idx:int=0; type_idx < param.childNodes.length; type_idx++) {
							result.push(extractValue(param.childNodes[type_idx]));
						}
					}
				}
			}
			return result;
		}
	
		/**
		 * The marshalling process, accepting a block of XML, a string description of the remote method, and an array of flash typed parameters.
		 *
		 * @return XMLNode containing the XML marshalled result
		 */
		public static function toXML(parent:XMLNode, method:String, params:Array):XMLNode
		{
			var mc:XMLNode = addNode(parent, "methodCall");
			addText(addNode(mc, "methodName"), method);
	
			var p:XMLNode = addNode(mc, "params");
			for (var i:int=0; i < params.length; i++) {
				addParameter(p, params[i]);
			}
	
			return mc;
		}
	
		private static function extractValue(value:XMLNode):*
		{
			var result:* = null;
	
			switch (value.nodeName) { 
				case "int":
				case "i4":
				case "double":
					result = Number(value.firstChild.nodeValue);
					break;
	
				case "boolean":
					result = Number(value.firstChild.nodeValue) ? true : false;
					break;
	
				case "array":
					var value_array:Array = new Array();
					var next_value:*;
					for (var data_idx:int=0; data_idx < value.firstChild.childNodes.length; data_idx++) {
						next_value = value.firstChild.childNodes[data_idx];
						value_array.push(extractValue(next_value.firstChild));
					}
					result = value_array;
					break;
	
				case "struct":
					var value_object:Object = new Object();
					for (var member_idx:int=0; member_idx < value.childNodes.length; member_idx++) {
						var member:Array = value.childNodes[member_idx];
						var m_name:String = member.childNodes[0].firstChild.nodeValue;
						var m_value:* = extractValue(member.childNodes[1].firstChild);
						value_object[m_name] = m_value;
					}
					result = value_object;
					break;
	
				case "dateTime.iso8601":
				case "Base64":
				case "string":
				default:
					result = value.firstChild.nodeValue.toString();
					break;
	
			}
	
			return result;
		}
	
		private static function addParameter(node:XMLNode, param:*):XMLNode
		{
			return addValue(addNode(node, "param"), param);
		}
	
		private static function addValue(node:XMLNode, value:*):XMLNode
		{
			var value_node:XMLNode = addNode(node, "value");
	
			if (typeof(value) == "string") {
				addText(addNode(value_node, "string"), value);
	
			} else if (typeof(value) == "number") {
				if (Math.floor(value) != value) {
					addText(addNode(value_node, "double"), value);
				} else {
					addText(addNode(value_node, "int"), value.toString());
				}
	
			} else if (typeof(value) == "boolean") {
				addText(addNode(value_node, "boolean"), value == false ? "0" : "1");
	
			} else if (value is Array) {
				var data:XMLNode = addNode(addNode(value_node, "array"), "data");
				for (var i:int=0; i < value.length; i++) {
					addValue(data, value[i]);
				}
			} else if (typeof(value) == "object") {
				// Special case where type is simple custom type is defined
				if (value.type != undefined && value.value != undefined) {
					addText(addNode(value_node, value.type), value.value);
				} else {
					var struct:XMLNode = addNode(value_node, "struct");
					for (var attr:String in value) {
						var member:XMLNode = addNode(struct, "member");
						addText(addNode(member, "name"), attr);
						addValue(member, value[attr]);
					}
				}
			}
	
			return node;
		}
	
		private static function addNode(parent:XMLNode, name:String):XMLNode
		{
			var child:XMLNode = XMLRPC.XMLFactory.createElement(name);
			parent.appendChild(child);
			return parent.lastChild;
		}
	
		private static function addText(parent:XMLNode, value:String):XMLNode
		{
			var child:XMLNode = XMLRPC.XMLFactory.createTextNode(value);
			parent.appendChild(child);
			return parent.lastChild;
		}
	
		private static function findNode(name:String, xml:XMLNode):XMLNode
		{
			if (xml.nodeName == name) {
				return xml;
			} else {
				var child:XMLNode = null;
				for (var i:String in xml.childNodes) {
					child = findNode(name, xml.childNodes[i]);
					if (child != null) {
						return child;
					}
				}
			}
			return null;
		}
	
	}
}