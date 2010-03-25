/*
 *This file is part of SparkWeb.
 *
 *SparkWeb is free software: you can redistribute it and/or modify
 *it under the terms of the GNU Lesser General Public License as published by
 *the Free Software Foundation, either version 3 of the License, or
 *(at your option) any later version.
 *
 *SparkWeb is distributed in the hope that it will be useful,
 *but WITHOUT ANY WARRANTY; without even the implied warranty of
 *MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *GNU Lesser General Public License for more details.
 *
 *You should have received a copy of the GNU Lesser General Public License
 *along with SparkWeb.  If not, see <http://www.gnu.org/licenses/>.
 */

package org.hasseg.externalMouseWheel {
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	* An event that informs of an external (JavaScript throught ExternalInterface) mouse wheel event 
	* (this is for Mac compability - Flash Player for OS X doesn't support mouse wheel events)
	* 
	* @author Ali Rantakari ( http://hasseg.org/blog ) - Feel free to use, given that this notice stays intact
	*/
	public final class ExternalMouseWheelEvent extends MouseEvent {
		
		/**
		* Defines the value of the type property of a mouseWheel event object.
		* 
		* @eventType mouseWheel
		*/
		public static const MOUSE_WHEEL:String = "mouseWheel";
		
		
		private var _stageX:Number;
		private var _stageY:Number;
		private var _delta:int;
		
		
		/**
		* Constructor
		*/
		public function ExternalMouseWheelEvent(aType:String, aDelta:int, aStageX:Number, aStageY:Number):void {
			
			super(aType);
			_delta = aDelta;
			_stageX = aStageX;
			_stageY = aStageY;
		}
		
		
		
		/**
		* @inheritDoc
		*/
		override public function clone():Event {
			
			return new ExternalMouseWheelEvent(type, _delta, _stageX, _stageY);
		}
		
		
		/**
		* @inheritDoc
		*/
		override public function get stageX():Number {
			return _stageX;
		}
		
		/**
		* @inheritDoc
		*/
		override public function get stageY():Number {
			return _stageY;
		}
		
		/**
		* @inheritDoc
		*/
		override public function get delta():int {
			return _delta;
		}
		/**
		* @private
		*/
		override public function set delta(aValue:int):void {
			_delta = aValue;
		}
		
	}

}
