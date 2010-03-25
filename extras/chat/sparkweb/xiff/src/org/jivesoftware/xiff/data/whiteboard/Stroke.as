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
	
	import org.jivesoftware.xiff.data.ISerializable;
	import flash.xml.XMLNode;
	
	/**
	 * A helper class that abstracts the serialization of strokes and
	 * provides an interface to access the properties
	 *
	 * @author Sean Treadway
	 * @since 2.0.0
	 * @availability Flash Player 7
	 * @toc-path Extensions/Whiteboard
	 * @toc-sort 1/2
	*/
	public class Stroke implements ISerializable
	{
		private var myColor:Number;
		private var myWidth:Number;
		private var myOpacity:Number;
	
		public function Stroke() { }
	
		/**
		 * Serializes the Stroke into the parent node.  Because the stroke
	     * serializes into the attributes of the XML node, it will directly modify
	     * the parent node passed.
		 *
		 * @availability Flash Player 7
		 * @param parent The parent node that this extension should be serialized into
		 * @return An indicator as to whether serialization was successful
		 */
		public function serialize( parent:XMLNode ):Boolean
		{
	        if (myColor) { parent.attributes['stroke'] = "#" + myColor.toString(16); }
	        if (myWidth) { parent.attributes['stroke-width'] = myWidth.toString(); }
	        if (myOpacity) { parent.attributes['stroke-opacity'] = myOpacity.toString(); }
	
	        return true;
	    }
	
		/**
		 * Extracts the known stroke attributes from the node
		 *
		 * @availability Flash Player 7
		 * @param parent The parent node that this extension should be serialized into
		 * @return An indicator as to whether serialization was successful
		 */
		public function deserialize( node:XMLNode ):Boolean
		{
	        if (node.attributes['stroke']) {
	            myColor = new Number('0x' + node.attributes['stroke'].slice(1));
	        }
	        if (node.attributes['stroke-width']) {
	            myWidth = new Number(node.attributes['stroke-width']);
	        }
	        if (node.attributes['stroke-opacity']) {
	            myOpacity = new Number(node.attributes['stroke-opacity']);
	        }
	
	        return true;
	    }
	
	    /**
	     * The value of the RGB color.  This is the same color format used by
	     * MovieClip.lineStyle
	     *
		 * @availability Flash Player 7
	     */
		public function get color():Number { return myColor ? myColor : 0; }
		public function set color(c:Number):void { myColor =c }
	
	    /**
	     * The width of the stroke in pixels.  This is in a format used by
	     * MovieClip.lineStyle
	     *
		 * @availability Flash Player 7
	     */
	    public function get width():Number { return myWidth ? myWidth : 1; }
	    public function set width(v:Number):void { myWidth = v; }
	
	    /**
	     * The opacity of the stroke, in percent. 100 is solid, 0 is transparent.
	     * This property can be used as the alpha parameter of MovieClip.lineStyle
	     *
		 * @availability Flash Player 7
	     */
	    public function get opacity():Number { return myOpacity ? myOpacity : 100; }
	    public function set opacity(v:Number):void { myOpacity = v; }
	}
}