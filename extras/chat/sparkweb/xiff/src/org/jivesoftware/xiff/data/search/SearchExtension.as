package org.jivesoftware.xiff.data.search{
	
	import flash.xml.XMLNode;
	
	import org.jivesoftware.xiff.data.Extension;
	import org.jivesoftware.xiff.data.ExtensionClassRegistry;
	import org.jivesoftware.xiff.data.IExtension;
	import org.jivesoftware.xiff.data.ISerializable;
	import org.jivesoftware.xiff.data.forms.FormExtension;
		
	/**
	 * Implements jabber:iq:search namespace.  Use this to perform user searches.
	 * Send an empty IQ.GET_TYPE packet with this extension and the return will either be a conflict, or the fields you will need to fill out.  
	 * Send a IQ.SET_TYPE packet to the server and with the fields that are listed in getRequiredFieldNames set on this extension.  
	 * Check the result and re-establish the connection with the new account.
	 *
	 * @author Daniel Henninger
	 * @since 2.0.0
	 * @param parent (Optional) The parent node used to build the XML tree.
	 * @availability Flash Player 7
	 * @toc-path Extensions/Search
	 * @toc-sort 1/2
	 */
	public class SearchExtension extends Extension implements IExtension, ISerializable
	{
		// Static class variables to be overridden in subclasses;
		public static var NS:String = "jabber:iq:search";
		public static var ELEMENT:String = "query";
	
		private var myFields:Object;
		private var myInstructionsNode:XMLNode;
		private var myItems:Array = [];
	
	    private static var staticDepends:Class = ExtensionClassRegistry;
	
		public function SearchExtension( parent:XMLNode=null )
		{
			super(parent);
			myFields = new Object();
		}
	
		public function getNS():String
		{
			return SearchExtension.NS;
		}
	
		public function getElementName():String
		{
			return SearchExtension.ELEMENT;
		}
	
	    /**
	     * Performs the registration of this extension into the extension registry.  
	     * 
		 * @availability Flash Player 7
	     */
	    public static function enable():void
	    {
	        ExtensionClassRegistry.register(SearchExtension);
	    }
		
		public function serialize( parentNode:XMLNode ):Boolean
		{
			if (!exists(getNode().parentNode)) {
				parentNode.appendChild(getNode().cloneNode( true ));
			}
			return true;
		}
	
		public function deserialize( node:XMLNode ):Boolean
		{
			setNode(node);
	
			var children:Array = getNode().childNodes;
			for (var i:String in children) {
	
				switch (children[i].nodeName) {
					case "instructions":
						myInstructionsNode = children[i];
						break;
						
					case "x":
						if (children[i].namespaceURI == FormExtension.NS) {
							var dataFormExt:FormExtension = new FormExtension(getNode());
							dataFormExt.deserialize(children[i]);
							this.addExtension(dataFormExt);
						}
						break;
						
					case "item":
						var item:SearchItem = new SearchItem(getNode());
						item.deserialize(children[i]);
						myItems.push(item);
						break;
	
					default:
						myFields[children[i].nodeName] = children[i];
						break;
				}
			}
			return true;
	
		}
	
		public function getRequiredFieldNames():Array
		{
			var fields:Array = new Array();
	
			for (var i:String in myFields) {
				fields.push(i);
			}
	
			return fields;
		}
		
		public function getAllItems():Array
		{
			return myItems;
		}
	
		public function get instructions():String 
		{ 
			return myInstructionsNode.firstChild.nodeValue; 
		}
	
		public function set instructions(val:String):void
		{
			myInstructionsNode = replaceTextNode(getNode(), myInstructionsNode, "instructions", val);
		}
	
		public function getField(name:String):String
		{
			return myFields[name].firstChild.nodeValue;
		}
	
		public function setField(name:String, val:String):void
		{
			myFields[name] = replaceTextNode(getNode(), myFields[name], name, val);
		}
				
	}
}