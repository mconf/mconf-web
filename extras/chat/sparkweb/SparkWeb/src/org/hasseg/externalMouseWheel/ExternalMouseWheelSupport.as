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
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;
	import mx.controls.Alert;
	import mx.core.Application;
	
	
	/**
	* Implements mouse wheel support for OS X.
	* This is done by catching mouse wheel events in JavaScript through the
	* ExternalInterface and dispatching them as ExternalMouseWheelEvents. 
	* The objects that the mouse wheel support should be enabled for have 
	* to be registered with this class, and the registration can be handled 
	* automatically (all InteractiveObjects on Stage) or manually (see 
	* <code>registerAutomatically</code>).
	* 
	* @see org.hasseg.externalMouseWheel.ExternalMouseWheelEvent
	* 
	* @author Ali Rantakari ( http://hasseg.org/blog ) - Feel free to use, given that this notice stays intact
	*/
	public final class ExternalMouseWheelSupport {
		
		private static var _registerAutomatically:Boolean = false;
		
		private var _automaticallyRegisteredObjects:Array = new Array();
		private var _manuallyRegisteredObjects:Array = new Array();
		
		
		
		private static var _INSTANCE:ExternalMouseWheelSupport = null;
		
		/**
		* @private
		*/
		public function ExternalMouseWheelSupport(aSingletonEnforcer:SingletonEnforcer):void {
			if (_INSTANCE != null) {
				throw new Error("You can't create more than one instance of this class because it is a singleton. Use ExternalMouseWheelSupport.instance to get a handle to it.");
			}else{
				initialize();
			}
		}
		
		/**
		* Reference to the singleton instance of this class
		*/
		public static function get instance():ExternalMouseWheelSupport {
			if (_INSTANCE == null) _INSTANCE = new ExternalMouseWheelSupport(new SingletonEnforcer());
			return _INSTANCE;
		}
		
		
		
		// BEGIN: private methods
		
		private function initialize():void {
			try {
				ExternalInterface.addCallback("dispatchExternalMouseWheelEvent", externalMouseWheelEventHandler);
				ExternalInterface.call("mw_initialize");
			}catch(e:Error){
				Alert.show("Error initializing ExternalMouseWheelSupport: "+e.toString());
			}
		}
		
		
		private function externalMouseWheelEventHandler(aDelta:int, aX:Number, aY:Number):void {
			
			var registeredObjects:Array = getRegisteredObjects();
			
			if (registeredObjects.length > 0) {
				
				// create array of objects and their levels in the displaylist
				var rObjs:Array = getDisplayListLevelsFor(registeredObjects);
				
				// see which ones pass a hittest with the mouse cursor
				var hitTestObjs:Array = rObjs.filter(function(aItem:*, aIndex:int, aArray:Array):Boolean {
					if (aItem.object.hitTestPoint(aX,aY)) return true;
					else return false;
				});
				
				/*
				var hitTestObjs:Array = new Array();
				for (var l:uint = 0; l < rObjs.length; l++) {
					if (rObjs[l].object.hitTestPoint(aX,aY)) hitTestObjs.push(rObjs[l]);
				}*/
				
				// see which ones of the remaining are highest in the displaylist
				var highestLevel:uint = 0;
				for (var m:uint = 0; m < hitTestObjs.length; m++) {
					if (hitTestObjs[m].level > highestLevel) highestLevel = hitTestObjs[m].level;
				}
				var onTheHighestLevel:Array = hitTestObjs.filter(function(aItem:*, aIndex:int, aArray:Array):Boolean {
					if (aItem.level == highestLevel) return true;
					else return false;
				});
				
				// pick the last one from the ones that have the highest level
				var highestInDisplayList:Object = {object:null, level:(-10000)};
				for (var n:uint = 0; n < onTheHighestLevel.length; n++) {
					if (onTheHighestLevel[n].level > highestInDisplayList.level) highestInDisplayList = onTheHighestLevel[n];
				}
				
				// make it dispatch a MouseEvent.MOUSE_WHEEL event
				if (highestInDisplayList.object != null) {
					if (highestInDisplayList.object.dispatchEvent)
						highestInDisplayList.object.dispatchEvent(new ExternalMouseWheelEvent(ExternalMouseWheelEvent.MOUSE_WHEEL, aDelta, aX, aY));
				}
				
			}
		}
		
		
		private function getRegisteredObjects():Array {
			if (_registerAutomatically == true) {
				_automaticallyRegisteredObjects = getAllInteractiveObjectsOnStage();
				return _automaticallyRegisteredObjects;
			}else{ 
				return _manuallyRegisteredObjects;
			}
		}
		
		
		private function getDisplayListLevelsFor(aObjs:Array):Array {
			
			var objs:Array = new Array();
			
			if (aObjs.length > 0) {
				
				if (aObjs[0].stage != null) {
					objs = travelDisplayList(aObjs[0].stage);
					var currLevel:uint = 0;
					
					function travelDisplayList(container:DisplayObjectContainer):Array {
						var retArr:Array = new Array();
						var child:DisplayObject;
						for (var i:uint=0; i < container.numChildren; i++) {
							currLevel++;
							child = container.getChildAt(i);
							if (aObjs.indexOf(child) != (-1)) retArr.push({object:child, level:currLevel});
							if (container.getChildAt(i) is DisplayObjectContainer) {
								var grandChildren:Array = travelDisplayList(DisplayObjectContainer(child));
								for (var j:uint = 0; j < grandChildren.length; j++) {
									retArr.push(grandChildren[j]);
								}
							}
						}
						return retArr;
					}
				}
				
			}
			
			return objs;
		}
		
		
		
		
		private function getAllInteractiveObjectsOnStage():Array {
			
			var objs:Array = new Array();
			
			if (Application.application) {
				
				objs = travelDisplayList(Application.application.stage);
				
				function travelDisplayList(container:DisplayObjectContainer):Array {
					var retArr:Array = new Array();
					var child:DisplayObject;
					for (var i:uint=0; i < container.numChildren; i++) {
						child = container.getChildAt(i);
						if (child is InteractiveObject) retArr.push(child);
						if (container.getChildAt(i) is DisplayObjectContainer) {
							var grandChildren:Array = travelDisplayList(DisplayObjectContainer(child));
							for (var j:uint = 0; j < grandChildren.length; j++) {
								retArr.push(grandChildren[j]);
							}
						}
					}
					return retArr;
				}
				
			}
			
			return objs;
		}
		
		// --end--: private methods
		
		
		
		
		
		
		
		
		/**
		* Whether or not to try and handle the registration of objects automatically
		* (note: automatic registration is a bit experimental / buggy)
		* 
		* @see org.hasseg.ExternalMouseWheel#registerObject
		* @see org.hasseg.ExternalMouseWheel#registerObjects
		* @see org.hasseg.ExternalMouseWheel#unRegisterObject
		*/
		public static function get registerAutomatically():Boolean {
			return _registerAutomatically;
		}
		/**
		* @private
		*/
		public static function set registerAutomatically(aValue:Boolean):void {
			_registerAutomatically = aValue;
		}
		
		
		
		
		
		/**
		* Registers an object to dispatch mouse wheel events also in OS X when the mouse
		* cursor is hovering on top of it and the wheel is used 
		* 
		* @param aObject	The object to register
		* 
		* @return True if object has been successfully registered, false if it already is registered
		* 
		* @see org.hasseg.ExternalMouseWheel#registerAutomatically
		* @see org.hasseg.ExternalMouseWheel#registerObjects
		* @see org.hasseg.ExternalMouseWheel#unRegisterObject
		*/
		public function registerObject(aObject:Object):Boolean {
			
			registerAutomatically = false;
			if (_manuallyRegisteredObjects.indexOf(aObject) == (-1)) {
				_manuallyRegisteredObjects.push(aObject);
				return true;
			}else{
				return false;
			}
		}
		
		/**
		* Registers several objects to dispatch mouse wheel events also in OS X when the mouse
		* cursor is hovering on top of them and the wheel is used 
		* 
		* @param aObjects	An Array of objects to register
		* 
		* @see org.hasseg.ExternalMouseWheel#registerObject
		* @see org.hasseg.ExternalMouseWheel#registerAutomatically
		* @see org.hasseg.ExternalMouseWheel#unRegisterObject
		*/
		public function registerObjects(aObjects:Array):void {
			
			registerAutomatically = false;
			for (var i:uint = 0; i < aObjects.length; i++) { registerObject(aObjects[i]); }
		}
		
		/**
		* Unregisters objects so that they will no longer dispatch 
		* mouse wheel events in OS X
		* 
		* @param aObject	The object to unregister
		* 
		* @return True if the object has been successfully unregistered, false if it was not registered in the first place
		* 
		* @see org.hasseg.ExternalMouseWheel#registerObject
		* @see org.hasseg.ExternalMouseWheel#registerObjects
		* @see org.hasseg.ExternalMouseWheel#registerAutomatically
		*/
		public function unRegisterObject(aObject:Object):Boolean {
			
			var foundArrayId:int = (-1);
			for (var i:uint = 0; i < _manuallyRegisteredObjects.length; i++) { if (_manuallyRegisteredObjects[i] == aObject) foundArrayId = i; }
			if (foundArrayId != (-1)) {
				_manuallyRegisteredObjects.splice(foundArrayId,1);
				return true;
			}else{
				return false;
			}
		}
		
		
		/**
		* Gets all of the manually registered objects
		* 
		* @return All of the registered objects
		*/
		public function get manuallyRegisteredObjects():Array {
			return _manuallyRegisteredObjects;
		}
		
		
	}
	
	
}

class SingletonEnforcer {}


