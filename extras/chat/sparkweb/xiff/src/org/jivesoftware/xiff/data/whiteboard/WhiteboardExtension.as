package org.jivesoftware.xiff.data.whiteboard{
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
	
	import org.jivesoftware.xiff.data.IExtension;
	import org.jivesoftware.xiff.data.ISerializable;
	
	import org.jivesoftware.xiff.data.Extension;
	import org.jivesoftware.xiff.data.ExtensionClassRegistry;
	
	import org.jivesoftware.xiff.data.whiteboard.Path;
	import flash.xml.XMLNode;
	
	 
	/**
	 * A message extension for whitboard exchange. This class is the base class
	 * for other extension classes such as Path
	 *
	 * All child whiteboard objects are contained and serialized by this class
	 *
	 * @author Sean Treadway
	 * @since 2.0.0
	 * @availability Flash Player 7
	 * @toc-path Extensions/Whiteboard
	 * @toc-sort 1/2
	 */
	public class WhiteboardExtension extends Extension implements IExtension, ISerializable
	{
		// Static class variables to be overridden in subclasses;
		public static var NS:String = "xiff:wb";
		public static var ELEMENT:String = "x";
	
	    private static var staticDepends:Class = ExtensionClassRegistry;
	
	    private var myPaths:Array;
		
		public function WhiteboardExtension( parent:XMLNode=null )
		{
			super( parent );
	        myPaths = new Array();
		}
	
		/**
		 * Gets the namespace associated with this extension.
		 * The namespace for the WhiteboardExtension is "xiff:wb".
		 *
		 * @return The namespace
		 * @availability Flash Player 7
		 */
		public function getNS():String
		{
			return WhiteboardExtension.NS;
		}
	
		/**
		 * Gets the element name associated with this extension.
		 * The element for this extension is "x".
		 *
		 * @return The element name
		 * @availability Flash Player 7
		 */
		public function getElementName():String
		{
			return WhiteboardExtension.ELEMENT;
		}
		
		/**
		 * Serializes the WhiteboardExtension data to XML for sending.
		 *
		 * @availability Flash Player 7
		 * @param parent The parent node that this extension should be serialized into
		 * @return An indicator as to whether serialization was successful
		 */
		public function serialize( parent:XMLNode ):Boolean
		{
	        getNode().removeNode();
	        var ext_node:XMLNode = XMLFactory.createElement(getElementName());
	        ext_node.attributes.xmlns = getNS();
	
	        for (var i:int=0; i < myPaths.length; i++) {
	            myPaths[i].serialize(ext_node);
	        }
	
	        parent.appendChild(ext_node);
	
			return true;
		}
	
	    /**
	     * Performs the registration of this extension into the extension registry.  
	     * 
		 * @availability Flash Player 7
	     */
	    public static function enable():void
	    {
	        ExtensionClassRegistry.register(WhiteboardExtension);
	    }
		
		/**
		 * Deserializes the WhiteboardExtension data.
		 *
		 * @availability Flash Player 7
		 * @param node The XML node associated this data
		 * @return An indicator as to whether deserialization was successful
		 */
		public function deserialize( node:XMLNode ):Boolean
		{
			setNode( node );
	        myPaths = new Array();
			
	        for (var i:int=0; i < node.childNodes.length; i++) {
	            var child:XMLNode = node.childNodes[i];
	            switch (child.nodeName) {
	                case "path":
	                    var path:Path = new Path();
	                    path.deserialize(child);
	                    myPaths.push(path);
	                    break;
	            }
	        }
			return true;
		}
	
	    /**
	     * The paths available in this whiteboard message
	     *
		 * @availability Flash Player 7
	     */
	    public function get paths():Array { return myPaths; }
	
	}
}