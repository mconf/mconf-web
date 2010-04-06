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
	import org.jivesoftware.xiff.data.XMLStanza;
	
	import org.jivesoftware.xiff.data.whiteboard.WhiteboardExtension;
	import org.jivesoftware.xiff.data.whiteboard.Stroke;
	import org.jivesoftware.xiff.data.whiteboard.Fill;
	import flash.xml.XMLNode;
	 
	/**
	 * A message extension for whitboard exchange. This class is the base class
	 * for other extension classes such as Path
	 *
	 * @author Sean Treadway
	 * @since 2.0.0
	 * @availability Flash Player 7
	 * @toc-path Extensions/Whiteboard
	 * @toc-sort 1/2
	 */
	public class Path implements ISerializable
	{
		// Static class variables to be overridden in subclasses;
		public static var ELEMENT:String = "path";
	
	    private var mySegments:Array;
	    private var myStroke:Stroke;
	    private var myFill:Fill;
	
	    private var _lastLocation:Object;
		
		public function Path( parent:XMLNode=null )
		{
			//super( parent );
	        mySegments = new Array();
			myStroke = new Stroke();
			myFill = new Fill();
		}
	
		/**
		 * Serializes the Path data to XML for sending.
		 *
		 * @availability Flash Player 7
		 * @param parent The parent node that this extension should be serialized into
		 * @return An indicator as to whether serialization was successful
		 */
		public function serialize( parent:XMLNode ):Boolean
		{
	        var node:XMLNode = XMLStanza.XMLFactory.createElement(Path.ELEMENT);
			node.attributes['p'] = serializeSegments();
	        stroke.serialize(node);
	        fill.serialize(node);
	        parent.appendChild(node);
	
			return true;
		}
		
		/**
		 * Deserializes the Path data.
		 *
		 * @availability Flash Player 7
		 * @param node The XML node associated this data
		 * @return true if deserialization was successful
		 */
		public function deserialize( node:XMLNode ):Boolean
		{
			var p:String = node.attributes['p'];
	
			// Divide and conquer, using commands as delims, joining
			// the results in prefix order
	        mySegments = new Array();
	        _lastLocation = new Object;
			loadNextCommand(p);
	
	        myStroke = new Stroke();
	        myStroke.deserialize(node);
	
	        myFill = new Fill();
	        myFill.deserialize(node);
	
			return true;
		}
	
		
		/**
		 * Creates the compact form of the segments
		 * in the fomrmat defined by SVG
		 * Example: M100 200L14 -15 L 125 100L150 200 300 400M10 20L30 40 50 60 z
	     *
		 * @returns String containging the compact version
		 * @availability Flash Player 7
		 */
		public function serializeSegments():String
		{
			var lastSeg:* = null;
			var p:String = '';
			var segs:Array = segments;
	
			for (var i:int=0; i < segs.length; i++) {
				var seg:* = segs[i];
	
				// Serialize the compact form (don't repeat command ids, remove extra spaces)
				if (lastSeg.to.x != seg.from.x && lastSeg.to.y != seg.from.y) {
					p += 'M' + seg.from.x + ' ' + seg.from.y + 'l';
				} else {
					p += ' ';
				}
	
				p += (seg.to.x - seg.from.x) + ' ' + (seg.to.y - seg.from.y);
	
				lastSeg = seg;
			}
			return p;
		}
	
	    /**
	     * Adds a start point and end point to this path.  The points will be rounded
	     * to the nearest integer to save serialization space.  10.0000001 takes 
	     * 4 times as much spaces as 10
	     *
	     * @param seg An object containing the properties "from" and "to" which
	     * are objects with the properties "x" and "y".  An example would 
	     * be { from: { x: 100, y: 200 }, to: { x: 200, y: 300 } }
	     * @return the segment parameter with the rounded values
	     * @see #addPoints
		 * @availability Flash Player 7
	     */
		public function addSegment(seg:Object):Object
		{
			seg.from.x = Math.round(seg.from.x);
			seg.from.y = Math.round(seg.from.y);
			seg.to.x = Math.round(seg.to.x);
			seg.to.y = Math.round(seg.to.y);
	
			if (mySegments.addItem) {
				mySegments.addItem(seg);
			} else {
				mySegments.push(seg);
			}
	        return seg;
		}
	
	    /**
	     * Another interface to add segments to this extension.  Instead of passing
	     * an object, you can pass parameters that will be converted into a segment
	     * and passed to addSegment
	     *
	     * @param from_x the start x coordinate
	     * @param from_y the start y coordinate
	     * @param to_x the destination x coordinate
	     * @param to_y the destination y coordinate
	     * @return the segment object created from the parameters with the rounded values
	     * from being modified in addSegment
		 * @availability Flash Player 7
	     */
		public function addPoints(from_x:Number, from_y:Number, to_x:Number, to_y:Number):Object
		{
	        return addSegment({from: {x: from_x, y: from_y}, to: {x: to_x, y: to_y}});
		}
	
	    /**
	     * The read-only list of start and end points encoded as an array of objects with the 
	     * format { from: { x: ###, y: ### }, to: { x: ###, y: ### } }
	     *
	     * You should not modify this list.  Segments should be added with addSegment
	     *
	     * @see #addSegment
		 * @availability Flash Player 7
	     */
	    public function get segments():Array { return mySegments; }
	
	    /**
	     * The Stroke object that contains the properties describing the stroke of this
	     * path
	     *
	     * @see org.jivesoftware.xiff.data.whiteboard.Stroke
		 * @availability Flash Player 7
	     */
	    public function get stroke():Stroke { return myStroke; }
	
	    /**
	     * The Fill object that contains the properties describing the fill of this
	     * path
	     *
	     * @see org.jivesoftware.xiff.data.whiteboard.Fill
		 * @availability Flash Player 7
	     */
	    public function get fill():Fill { return myFill; }
	
	    // PRIVATE METHODS
	
		private static function indexOfNextCommand(str:String):Number
		{
			for (var i:int=0; i < str.length; i++) {
				if (str.charAt(i) >= 'A' && str.charAt(i) <= 'Z' ||
					str.charAt(i) >= 'a' && str.charAt(i) <= 'z')
				{
					return i;
				}
			}
			return -1;
		}
	
		private function loadNextCommand(str:String):void
		{
			// Example
			// M100 200L14 -15 L 125 100L150 200 300 400M10 20L30 40 50 60 z
			// Command ID or space acts as delimeter
			// Parameter tuples inherit last command
	
			// Find the next command to split on, so we preserve order
			var idx:Number = indexOfNextCommand(str);
			if (idx >= 0) {
				var cmd:String = str.charAt(idx);
				var commands:Array = str.split(cmd);
				for (var i:int=0; i < commands.length; i++) {
					if (commands[i].length > 0) {
						loadCommand(cmd, commands[i]);
					}
				}
			}
		}
	
		private function loadCommand(cmd:String, str:String):void
		{
			// We have a command, with possible other commands embedded
			// split out the other commands, and process our parameters
	
			var idx:Number = indexOfNextCommand(str);
			var params:Array;
	
			if (idx > 0) {
				params = str.slice(0, idx).split(' ');
			} else {
				params = str.split(' ');
			}
	
			// Handle any parameterless commands here like closepath
	
	
			// We have our parameters, now pull them out 
			// depending on the command
	
			while (params.length > 0) {
				if (params[0].length == 0) {
					params.shift();
				} else {
					var current:Object;
	
					switch (cmd) {
						case "M":
							_lastLocation = {
								x: Number(params.shift()), 
								y: Number(params.shift())
							};
							break;
	
						case "L":
							current = {
								x: Number(params.shift()), 
								y: Number(params.shift())
							};
							addSegment({from: _lastLocation, to: current });
							_lastLocation = current;
							break;
	
						case "l":
							current = {
								x: _lastLocation.x + Number(params.shift()), 
								y: _lastLocation.y + Number(params.shift())
							};
							addSegment({from: _lastLocation, to: current});
							_lastLocation = current;
							break;
							
						default:
							trace("Unknown parameter for command: " + cmd);
							params.shift();
							break;
					}
				}
			}
	
			loadNextCommand(str.slice(idx));
		}
	
	}
}