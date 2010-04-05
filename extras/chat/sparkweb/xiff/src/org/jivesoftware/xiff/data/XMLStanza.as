package org.jivesoftware.xiff.data{
	/*
	 * Copyright (C) 2003-2007 
	 * Nick Velloff <nick.velloff@gmail.com>
	 * Derrick Grigg <dgrigg@rogers.com>
	 * Sean Voisen <sean@voisen.org>
	 * Sean Treadway <seant@oncotype.dk>
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
	
	import org.jivesoftware.xiff.data.INodeProxy;
	import flash.xml.XMLNode;
	import flash.xml.XMLDocument;
	
	/**
	 * This is a base class for all classes that encapsulate XML stanza data. It provides
	 * a set of methods that faciliate easy manipulation of XML data.
	 * 
	 * @author Sean Treadway
	 * @since 2.0.0
	 * @availability Flash Player 7
	 * @toc-path Data/Base Classes
	 * @toc-sort 1/2
	 */
	public class XMLStanza extends ExtensionContainer implements INodeProxy, IExtendable
	{
	    // Global factory for all XMLNode generation
		public static var XMLFactory:XMLDocument = new XMLDocument();
		private var myXML:XMLNode;
	
		public function XMLStanza()
		{
			super();
			myXML = XMLStanza.XMLFactory.createElement('');
		}
	
		/**
		 * A helper method to determine if a value is both not null
		 * and not undefined.
		 *
		 * @availability Flash Player 7
		 * @param val The value to check for existance
		 * @return Whether the value checked is both not null and not undefined
		 */
		//private static function exists( val:* ):Boolean
		public static function exists( val:* ):Boolean
		{
			if( val != null && val !== undefined )
				return true;
			
			return false;
		}
	
		/**
		 * Adds a simple text node to the parent node specified.
		 *
		 * @param parent The parent node that the newly created node should be appended onto
		 * @param elementName The element name of the new node
		 * @param value The value of the new node
		 * @return A reference to the new node
		 * @availability Flash Player 7
		 */
		public function addTextNode( parent:XMLNode, elementName:String, value:String):XMLNode
		{
			var newNode:XMLNode = XMLStanza.XMLFactory.createElement(elementName);
			newNode.appendChild(XMLFactory.createTextNode(value));
			parent.appendChild(newNode);
			return newNode;
		}
	
		/**
		 * Ensures that a node with a specific element name exists in the stanza. If it doesn't, then
		 * the node is created and returned.
		 *
		 * @param node The node to ensure
		 * @param elementName The element name to check for existance
		 * @return The node if it already exists, else a newly created node with the element name provided
		 * @availability Flash Player 7
		 */
		public function ensureNode( node:XMLNode, elementName:String ):XMLNode
		{
			if (!exists(node)) {
				node = XMLStanza.XMLFactory.createElement(elementName);
	            getNode().appendChild(node);
			}
			return node;
		}
	
		/**
		 * Replaces one node in the stanza with another simple text node.
		 *
		 * @param parent The parent node to start at when searching for replacement
		 * @param original The node to replace
		 * @param elementName The new node's element name
		 * @param value The new node's value
		 * @return The newly created node
		 * @availability Flash Player 7
		 */
		public function replaceTextNode( parent:XMLNode, original:XMLNode, elementName:String, value:String ):XMLNode
		{
			var newNode:XMLNode;
	
			// XXX Investigate on whether a remove/create is as efficient
			// as replacing the contents of the first text element nodeValue
			
			// Through the magic of AS, this will not fail if the 
			// original node is undefined
			
			//if (original == null) original = XMLStanza.XMLFactory.createElement('');
			if (original != null){
				original.removeNode();
			}
	
			if (exists(value)) {
				newNode = XMLStanza.XMLFactory.createElement(elementName);
				if (value.length > 0) {
					newNode.appendChild(XMLStanza.XMLFactory.createTextNode(value));
				}
				parent.appendChild(newNode);
			}
	
			return newNode;
		}
		
		/**
		 * Returns a reference to the stanza in XML form.
		 *
		 * @return The stanza as XML
		 * @availability Flash Player 7
		 */
		public function getNode():XMLNode
		{
			return myXML;
		}
	
		/**
		 * Sets the XML node that should be used for this stanza's internal XML representation.
		 *
		 * @return Whether the node set was successful
		 * @availability Flash Player 7
		 */
		public function setNode( node:XMLNode ):Boolean
		{
			//var oldParent:XMLNode = (myXML.parentNode == null)?(XMLStanza.XMLFactory.createElement('')):(myXML.parentNode);
			var oldParent:XMLNode = myXML.parentNode;
			
			// Transfer ownership from the node's parent to our old parent
	
			myXML.removeNode();
			myXML = node;
	
			if (exists(myXML) && oldParent != null) {
				oldParent.appendChild(myXML);
			}
	
			return true;
		}
	}
}