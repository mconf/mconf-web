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
	
	import org.jivesoftware.xiff.data.ISerializable;
	import org.jivesoftware.xiff.data.XMLStanza;
	
	/**
	 * This class is used by the FormExtension class for managing fields
	 * as fields have multiple behaviors depending on the type of the form
	 * while containing different kinds of data, some optional some not.
	 *
	 *
	 * @author Sean Treadway
	 * @since 2.0.0
	 * @availability Flash Player 7
	 * @see org.jivesoftware.xiff.data.forms.FormExtension
	 * @see http://www.jabber.org/jeps/jep-0004.html
	 * @param parent The parent XMLNode
	 * @toc-path Extensions/Instant Messaging
	 * @toc-sort 1/2
	 */
	public class FormField extends XMLStanza implements ISerializable
	{
		public static var ELEMENT:String = "field";
	
	    private var myDescNode:XMLNode;
	    private var myRequiredNode:XMLNode;
	    private var myValueNodes:Array;
	    private var myOptionNodes:Array;
		
		public function FormField() { super(); }
		
		/**
		 * Serializes the FormField data to XML for sending.
		 *
		 * @availability Flash Player 7
		 * @param parent The parent node that this item should be serialized into
		 * @return An indicator as to whether serialization was successful
		 */
		public function serialize( parent:XMLNode ):Boolean
		{
			getNode().nodeName = FormField.ELEMENT;
	
			if( parent != getNode().parentNode ) {
				parent.appendChild( getNode().cloneNode( true ) );
			}
	
			return true;
		}
		
		/**
		 * Deserializes the FormField data.
		 *
		 * @availability Flash Player 7
		 * @param node The XML node associated this data
		 * @return An indicator as to whether deserialization was successful
		 */
		public function deserialize( node:XMLNode ):Boolean
		{
			setNode( node );
	
	        myValueNodes = new Array();
	        myOptionNodes = new Array();
	
			var children:Array = node.childNodes;
			for( var i:String in children ) {
	            var c:XMLNode = children[i];
	
				switch( children[i].nodeName ) {
	                case "desc": myDescNode = c; break;
	                case "required": myRequiredNode = c; break;
	                case "value": myValueNodes.push(c); break;
	                case "option": myOptionNodes.push(c); break;
				}
			}
			
			return true;
		}
		
	    /**
	     * The name of this field used by the application or server.
	     *
	     * Note: this serializes to the <code>var</code> attribute on the
	     * field node.  Since <code>var</code> is a reserved word in ActionScript
	     * this field uses <code>name</code> to describe the name of this field.
	     *
		 * @availability Flash Player 7
	     */
	    public function get name():String { return getNode().attributes["var"]; }
	    public function set name(val:String) :void
	    { 
	        getNode().attributes["var"] = val; 
	    }
	
	    /**
	     * The type of this field used by user interfaces to render an approprite 
	     * control to represent this field.
	     *
	     * May be one of the following:
	     *
	     * <code>FormExtension.FIELD_TYPE_BOOLEAN</code>
	     * <code>FormExtension.FIELD_TYPE_FIXED</code>
	     * <code>FormExtension.FIELD_TYPE_HIDDEN</code>
	     * <code>FormExtension.FIELD_TYPE_JID_MULTI</code>
	     * <code>FormExtension.FIELD_TYPE_JID_SINGLE</code>
	     * <code>FormExtension.FIELD_TYPE_LIST_MULTI</code>
	     * <code>FormExtension.FIELD_TYPE_LIST_SINGLE</code>
	     * <code>FormExtension.FIELD_TYPE_TEXT_MULTI</code>
	     * <code>FormExtension.FIELD_TYPE_TEXT_PRIVATE</code>
	     * <code>FormExtension.FIELD_TYPE_TEXT_SINGLE</code>
	     *
	     * @see http://www.jabber.org/jeps/jep-0004.html#protocol-fieldtypes
		 * @availability Flash Player 7
	     */
	    public function get type():String { return getNode().attributes.type; }
	    public function set type(val:String) :void
	    { 
	        getNode().attributes.type = val; 
	    }
	
	    /**
	     * The label of this field used by user interfaces to render a descriptive
	     * title of this field
	     *
		 * @availability Flash Player 7
	     */
	    public function get label():String { return getNode().attributes.label; }
	    public function set label(val:String) :void
	    { 
	        getNode().attributes.label = val; 
	    }
	
	    /**
	     * The chosen value for this field.  In forms with a type 
	     * <code>FormExtension.REQUEST_TYPE</code> this is typically the default
	     * value of the field.
	     *
	     * Applies to the following field types:
	     *
	     * <code>FormExtension.FIELD_TYPE_BOOLEAN</code>
	     * <code>FormExtension.FIELD_TYPE_FIXED</code>
	     * <code>FormExtension.FIELD_TYPE_HIDDEN</code>
	     * <code>FormExtension.FIELD_TYPE_JID_SINGLE</code>
	     * <code>FormExtension.FIELD_TYPE_LIST_SINGLE</code>
	     * <code>FormExtension.FIELD_TYPE_LIST_MULTI</code>
	     * <code>FormExtension.FIELD_TYPE_TEXT_PRIVATE</code>
	     * <code>FormExtension.FIELD_TYPE_TEXT_SINGLE</code>
	     *
	     * Suggested values can typically be retrieved in <code>getAllOptions</code>
	     *
		 * @availability Flash Player 7
	     */
	    public function get value():String {
	    	try 
	    	{
	    		if (myValueNodes[0] != null && myValueNodes[0].firstChild != null)
	    			return myValueNodes[0].firstChild.nodeValue; 
	    	}
	    	catch (error:Error)
	    	{
				trace(error.getStackTrace());
		    }
		    return null;
	    }
	    
	    public function set value(val:String) :void
	    {
	    	if (myValueNodes == null)
	    		myValueNodes = new Array();

	        myValueNodes[0] = replaceTextNode(getNode(), myValueNodes[0], "value", val);
	    }
	
	    /**
	     * The values for this multiple field.  In forms with a type 
	     * <code>FormExtension.REQUEST_TYPE</code> these are typically the existing
	     * values of the field.
	     *
	     * Applies to the following field types:
	     *
	     * <code>FormExtension.FIELD_TYPE_JID_MULTI</code>
	     * <code>FormExtension.FIELD_TYPE_LIST_MULTI</code>
	     * <code>FormExtension.FIELD_TYPE_TEXT_MULTI</code>
	     *
	     * @returns Array containing strings representing the values of this field
		 * @availability Flash Player 7
	     */
	    public function getAllValues():Array
	    {
	        var res:Array = [];
	        for each(var valueNode:XMLNode in myValueNodes)
	        {
	            res.push(valueNode.firstChild.nodeValue);
	        }
	        return res;
	    }
	
	    /**
	     * Sets all the values of this field from an array of strings
	     *
	     * @param val Array of Strings
		 * @availability Flash Player 7
	     */
	    public function setAllValues(val:Array) :void
	    {
	        for each(var v:XMLNode in myValueNodes) {
	            v.removeNode();
	        }
	
	        myValueNodes = val.map( 
	        	function(value:String, index:uint, arr:Array):* { 
	        		return replaceTextNode(getNode(), undefined, "value", value); 
	        	}
	        );
	    }
	
	    /**
	     * If options are provided for possible selections of the value they are listed
	     * here.
	     *
	     * Applies to the following field types:
	     *
	     * <code>FormExtension.FIELD_TYPE_JID_MULTI</code>
	     * <code>FormExtension.FIELD_TYPE_JID_SINGLE</code>
	     * <code>FormExtension.FIELD_TYPE_LIST_MULTI</code>
	     * <code>FormExtension.FIELD_TYPE_LIST_SINGLE</code>
	     *
	     * @returns Array of objects with the properties <code>label</code> and <code>value</code>
		 * @availability Flash Player 7
	     */
	    public function getAllOptions():Array
	    {
	        return myOptionNodes.map(
	        	function(optionNode:XMLNode, index:uint, arr:Array):Object {
	        		return {
	        			label: optionNode.attributes.label,
	                	value: optionNode.firstChild.firstChild.nodeValue
	        		}
	        	}
	        );
	    }
	
	    /**
	     * Sets all the options available from an array of objects
	     *
	     * @param Array containing objects with the properties <code>label</code> and
	     * <code>value</code>
		 * @availability Flash Player 7
	     */
	    public function setAllOptions(val:Array):void
	    {
	        for each(var optionNode:XMLNode in myOptionNodes) {
	        	optionNode.removeNode();
	        }
	
	        myOptionNodes = val.map(
	        	function(v:Object, index:uint, arr:Array):XMLNode {
	        		var option:XMLNode = replaceTextNode(getNode(), undefined, "value", v.value);
	            	option.attributes.label = v.label;
	            	return option;
	        	}
	        );
	    }
	}
	
}