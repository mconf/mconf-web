package org.jivesoftware.xiff.data.forms{
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
	
	import flash.xml.XMLNode;
	
	import org.jivesoftware.xiff.data.Extension;
	import org.jivesoftware.xiff.data.ExtensionClassRegistry;
	import org.jivesoftware.xiff.data.IExtension;
	import org.jivesoftware.xiff.data.ISerializable;
	import org.jivesoftware.xiff.data.XMLStanza;
	
	/**
	 * Implements the base functionality shared by all MUC extensions
	 *
	 * @author Sean Treadway
	 * @since 2.0.0
	 * @param parent (Optional) The containing XMLNode for this extension
	 * @availability Flash Player 7
	 * @toc-path Extensions/Conferencing
	 * @toc-sort 1/2
	 */
	//public class FormExtension extends Extension implements ISerializable, IExtension
	public class FormExtension extends Extension implements IExtension, ISerializable
	{
	    public static var FIELD_TYPE_BOOLEAN:String = "boolean";
	    public static var FIELD_TYPE_FIXED:String = "fixed";
	    public static var FIELD_TYPE_HIDDEN:String = "hidden";
	    public static var FIELD_TYPE_JID_MULTI:String = "jid-multi";
	    public static var FIELD_TYPE_JID_SINGLE:String = "jid-single";
	    public static var FIELD_TYPE_LIST_MULTI:String = "list-multi";
	    public static var FIELD_TYPE_LIST_SINGLE:String = "list-single";
	    public static var FIELD_TYPE_TEXT_MULTI:String = "text-multi";
	    public static var FIELD_TYPE_TEXT_PRIVATE:String = "text-private";
	    public static var FIELD_TYPE_TEXT_SINGLE:String = "text-single";
	
	    public static var REQUEST_TYPE:String = "form";
	    public static var RESULT_TYPE:String = "result";
	    public static var SUBMIT_TYPE:String = "submit";
	    public static var CANCEL_TYPE:String = "cancel";
	
	    public static var NS:String = "jabber:x:data";
	    public static var ELEMENT:String = "x";
	
		//private static var isStaticConstructed:Boolean = enable();
		//private static var staticDependencies:Array = [ ExtensionClassRegistry ];
	
		private var myItems:Array;
		private var myFields:Array;
	    private var myReportedFields:Array;
	
	    private var myInstructionsNode:XMLNode;
	    private var myTitleNode:XMLNode;
	
		public function FormExtension( parent:XMLNode=null )
		{
			super(parent);
			myItems = new Array();
			myFields = new Array();
			myReportedFields = new Array();
		}
	
		public function getNS():String
		{
			return FormExtension.NS;
		}
	
		public function getElementName():String
		{
			return FormExtension.ELEMENT;
		}
		
		public static function enable():Boolean
	    {
	        ExtensionClassRegistry.register(FormExtension);
	        return true;
	    }
		/**
		 * Called when this extension is being put back on the network.  Perform any further serialization for Extensions and items
		 */
		public function serialize( parent:XMLNode ):Boolean
		{
			var node:XMLNode = getNode();
	
			for each (var field:FormField in myFields) {
				if (!field.serialize(node))
					return false;
			}
	
			if (parent != node.parentNode) {
				parent.appendChild(node.cloneNode(true));
			}
	
			return true;
		}
	
		public function deserialize( node:XMLNode ):Boolean
		{
			setNode(node);
	
			removeAllItems();
			removeAllFields();
	
			for each( var c:XMLNode in node.childNodes ) {
				var field:FormField;
				switch( c.nodeName )
				{
	                case "instructions": myInstructionsNode = c; break;
	                case "title": myTitleNode = c; break;
	                case "reported":
	                	for each(var reportedFieldXML:XMLNode in c.childNodes) 
	                	{
	                		field = new FormField();
	                		field.deserialize(reportedFieldXML);
	                		myReportedFields.push(field);
	                	}
	                    break;
	
					case "item":
						var itemFields:Array = [];
	                    for each(var itemFieldXML:XMLNode in c.childNodes) 
	                    {
	                        field = new FormField();
	                        field.deserialize(itemFieldXML);
	                        itemFields.push(field);
	                    }
	                    myItems.push(itemFields);
						break;
	
	                case "field":
	                    field = new FormField();
	                    field.deserialize(c);
	                    myFields.push(field);
	                    break;
				}
			}
			return true;
		}
	
	    /**
	     * This is an accessor to the hidden field type <code>FORM_TYPE</code> 
	     * easily check what kind of form this is.
	     *
		 * @return String the registered namespace of this form type
	     * @see http://www.jabber.org/jeps/jep-0068.html
		 * @availability Flash Player 7
	     */
	    public function getFormType():String
	    {
	        // Most likely at the start of the array
	        for each(var field:FormField in myFields) {
	        	if(field.name == "FORM_TYPE")
	        		return field.value;
	        }
	        return "";
	    }
	
		/**
		 * Item interface to array of fields if they are contained in an "item" element
		 *
		 * @return Array containing Arrays of FormFields objects
		 * @availability Flash Player 7
		 */
	    public function getAllItems():Array 
	    { 
	        return myItems; 
	    }
	    
	    /**
	    * Returns the request form field
	    * 
	    * @param value the name of the form field to retrieve
	    * @returns FormField the matching form field
	    */
	    public function getFormField(value:String):FormField
	    {
	    	 for each (var field:FormField in myFields)
	    	 {
			 	if (field.name == value)
			 		return field;
			 }
			 return null;
	    }
	
		/**
		 * Item interface to array of fields if they are contained in an "item" element
		 *
		 * @return Array of FormFields objects
		 * @availability Flash Player 7
		 */
	    public function getAllFields():Array 
	    { 
	        return myFields; 
	    }
	
	    /**
	     * Sets the fields given a fieldmap object containing keys of field names
	     * and values of value arrays
	     *
	     * @param fieldmap Object in format obj[key:String].value:Array
	     * @availability Flash Player 7
	     */
	    public function setFields(fieldmap:Object):void
	    {
	        removeAllFields();
	        for (var f:String in fieldmap) {
	            var field:FormField = new FormField();
	            field.name = f;
	            field.setAllValues(fieldmap[f]);
	            myFields.push(field);
	        }
	    }
	
		/**
		 * Use this method to remove all items.
		 *
		 * @availability Flash Player 7
		 */
		public function removeAllItems():void
		{
			for each(var item:FormField in myItems) {
	            for each(var i:* in item) {
	                i.getNode().removeNode();
	                i.setNode(null);
	            }
			}
		 	myItems = [];
		}
		/**
		 * Use this method to remove all fields.
		 *
		 * @availability Flash Player 7
		 */
		public function removeAllFields():void
		{
			for each(var item:FormField in myFields) {
	            for each(var i:* in item) {
	                i.getNode().removeNode();
	                i.setNode(null);
	            }
			}
		 	myFields = [];
		}
	
	    /**
	     * Instructions describing what to do with this form
	     *
		 * @availability Flash Player 7
	     */
	    public function get instructions():String { return myInstructionsNode.firstChild.nodeValue; }
	    public function set instructions(val:String) :void
	    { 
	        myInstructionsNode = replaceTextNode(getNode(), myInstructionsNode, "instructions", val);
	    }
	
	    /**
	     * The title of this form
	     *
		 * @availability Flash Player 7
	     */
	    public function get title():String { return myTitleNode.firstChild.nodeValue; }
	    public function set title(val:String) :void
	    { 
	        myTitleNode = replaceTextNode(getNode(), myTitleNode, "Title", val);
	    }
	
	    /**
	     * Array of fields found in individual items due to a search query result
	     *
	     * @returns Array of FormField objects containing information about the fields
	     * in the fields retrieved by getAllItems
		 * @availability Flash Player 7
	     */
	    public function getReportedFields():Array
	    { 
	        return myReportedFields; 
	    }
	
	    /**
	     * The type of form.  May be one of the following:
	     *
	     * <code>FormExtension.REQUEST_TYPE</code>
	     * <code>FormExtension.RESULT_TYPE</code>
	     * <code>FormExtension.SUBMIT_TYPE</code>
	     * <code>FormExtension.CANCEL_TYPE</code>
	     *
		 * @availability Flash Player 7
	     */
	
	    public function get type():String { return getNode().attributes.type; }
	    public function set type(val:String) :void
	    { 
	        // TODO ensure it is in the enumeration of "cancel", "form", "result", "submit"
	        // TODO Change the behavior of the serialization depending on the type
	        getNode().attributes.type = val; 
	    }
	}
}