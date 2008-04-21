/**
  *
  *  Copyright 2005 Sabre Airline Solutions
  *
  *  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
  *  file except in compliance with the License. You may obtain a copy of the License at
  *
  *         http://www.apache.org/licenses/LICENSE-2.0
  *
  *  Unless required by applicable law or agreed to in writing, software distributed under the
  *  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
  *  either express or implied. See the License for the specific language governing permissions
  *  and limitations under the License.
  **/
//-------------------- ricoDragAndDrop.js
Rico.DragAndDrop = Class.create();

Rico.DragAndDrop.prototype = {

   initialize: function() {
      this.dropZones                = new Array();
      this.draggables               = new Array();
      this.currentDragObjects       = new Array();
      this.dragElement              = null;
      this.lastSelectedDraggable    = null;
      this.currentDragObjectVisible = false;
      this.interestedInMotionEvents = false;
      this._mouseDown = this._mouseDownHandler.bindAsEventListener(this);
      this._mouseMove = this._mouseMoveHandler.bindAsEventListener(this);
      this._mouseUp = this._mouseUpHandler.bindAsEventListener(this);
   },

   registerDropZone: function(aDropZone) {
      this.dropZones[ this.dropZones.length ] = aDropZone;
   },

   deregisterDropZone: function(aDropZone) {
      var newDropZones = new Array();
      var j = 0;
      for ( var i = 0 ; i < this.dropZones.length ; i++ ) {
         if ( this.dropZones[i] != aDropZone )
            newDropZones[j++] = this.dropZones[i];
      }

      this.dropZones = newDropZones;
   },

   clearDropZones: function() {
      this.dropZones = new Array();
   },

   registerDraggable: function( aDraggable ) {
      this.draggables[ this.draggables.length ] = aDraggable;
      this._addMouseDownHandler( aDraggable );
   },

   clearSelection: function() {
      for ( var i = 0 ; i < this.currentDragObjects.length ; i++ )
         this.currentDragObjects[i].deselect();
      this.currentDragObjects = new Array();
      this.lastSelectedDraggable = null;
   },

   hasSelection: function() {
      return this.currentDragObjects.length > 0;
   },

   setStartDragFromElement: function( e, mouseDownElement ) {
      this.origPos = RicoUtil.toDocumentPosition(mouseDownElement);
      this.startx = e.screenX - this.origPos.x
      this.starty = e.screenY - this.origPos.y
      //this.startComponentX = e.layerX ? e.layerX : e.offsetX;
      //this.startComponentY = e.layerY ? e.layerY : e.offsetY;
      //this.adjustedForDraggableSize = false;

      this.interestedInMotionEvents = this.hasSelection();
      this._terminateEvent(e);
   },

   updateSelection: function( draggable, extendSelection ) {
      if ( ! extendSelection )
         this.clearSelection();

      if ( draggable.isSelected() ) {
         this.currentDragObjects=this.currentDragObjects.without(draggable);
         draggable.deselect();
         if ( draggable == this.lastSelectedDraggable )
            this.lastSelectedDraggable = null;
      }
      else {
         this.currentDragObjects[ this.currentDragObjects.length ] = draggable;
         draggable.select();
         this.lastSelectedDraggable = draggable;
      }
   },

   _mouseDownHandler: function(e) {
      if ( arguments.length == 0 )
         e = event;

      // if not button 1 ignore it...
      var nsEvent = e.which != undefined;
      if ( (nsEvent && e.which != 1) || (!nsEvent && e.button != 1))
         return;

      var eventTarget      = e.target ? e.target : e.srcElement;
      var draggableObject  = eventTarget.draggable;

      var candidate = eventTarget;
      while (draggableObject == null && candidate.parentNode) {
         candidate = candidate.parentNode;
         draggableObject = candidate.draggable;
      }
   
      if ( draggableObject == null )
         return;

      this.updateSelection( draggableObject, e.ctrlKey );

      // clear the drop zones postion cache...
      if ( this.hasSelection() )
         for ( var i = 0 ; i < this.dropZones.length ; i++ )
            this.dropZones[i].clearPositionCache();

      this.setStartDragFromElement( e, draggableObject.getMouseDownHTMLElement() );
   },


   _mouseMoveHandler: function(e) {
      var nsEvent = e.which != undefined;
      if ( !this.interestedInMotionEvents ) {
         //this._terminateEvent(e);
         return;
      }

      if ( ! this.hasSelection() )
         return;

      if ( ! this.currentDragObjectVisible )
         this._startDrag(e);

      if ( !this.activatedDropZones )
         this._activateRegisteredDropZones();

      //if ( !this.adjustedForDraggableSize )
      //   this._adjustForDraggableSize(e);

      this._updateDraggableLocation(e);
      this._updateDropZonesHover(e);

      this._terminateEvent(e);
   },

   _makeDraggableObjectVisible: function(e)
   {
      if ( !this.hasSelection() )
         return;

      var dragElement;
      if ( this.currentDragObjects.length > 1 )
         dragElement = this.currentDragObjects[0].getMultiObjectDragGUI(this.currentDragObjects);
      else
         dragElement = this.currentDragObjects[0].getSingleObjectDragGUI();

      // go ahead and absolute position it...
      if ( RicoUtil.getElementsComputedStyle(dragElement, "position")  != "absolute" )
/*      if (Element.getStyle(dragElement,'position')=='absolute')*/
         dragElement.style.position = "absolute";

      // need to parent him into the document...
      if ( dragElement.parentNode == null || dragElement.parentNode.nodeType == 11 )
         document.body.appendChild(dragElement);

      this.dragElement = dragElement;
      this._updateDraggableLocation(e);

      this.currentDragObjectVisible = true;
   },

   /**
   _adjustForDraggableSize: function(e) {
      var dragElementWidth  = this.dragElement.offsetWidth;
      var dragElementHeight = this.dragElement.offsetHeight;
      if ( this.startComponentX > dragElementWidth )
         this.startx -= this.startComponentX - dragElementWidth + 2;
      if ( e.offsetY ) {
         if ( this.startComponentY > dragElementHeight )
            this.starty -= this.startComponentY - dragElementHeight + 2;
      }
      this.adjustedForDraggableSize = true;
   },
   **/

   _leftOffset: function(e) {
	   return e.offsetX ? document.body.scrollLeft : 0
	},

   _topOffset: function(e) {
	   return e.offsetY ? document.body.scrollTop:0
	},

		
   _updateDraggableLocation: function(e) {
      var dragObjectStyle = this.dragElement.style;
      dragObjectStyle.left = (e.screenX + this._leftOffset(e) - this.startx) + "px"
      dragObjectStyle.top  = (e.screenY + this._topOffset(e) - this.starty) + "px";
   },

   _updateDropZonesHover: function(e) {
      var n = this.dropZones.length;
      for ( var i = 0 ; i < n ; i++ ) {
         if ( ! this._mousePointInDropZone( e, this.dropZones[i] ) )
            this.dropZones[i].hideHover();
      }

      for ( var i = 0 ; i < n ; i++ ) {
         if ( this._mousePointInDropZone( e, this.dropZones[i] ) ) {
            if ( this.dropZones[i].canAccept(this.currentDragObjects) )
               this.dropZones[i].showHover();
         }
      }
   },

   _startDrag: function(e) {
      for ( var i = 0 ; i < this.currentDragObjects.length ; i++ )
         this.currentDragObjects[i].startDrag();

      this._makeDraggableObjectVisible(e);
   },

   _mouseUpHandler: function(e) {
      if ( ! this.hasSelection() )
         return;

      var nsEvent = e.which != undefined;
      if ( (nsEvent && e.which != 1) || (!nsEvent && e.button != 1))
         return;

      this.interestedInMotionEvents = false;

      if ( this.dragElement == null ) {
         this._terminateEvent(e);
         return;
      }

      if ( this._placeDraggableInDropZone(e) )
         this._completeDropOperation(e);
      else {
         this._terminateEvent(e);
         Rico.animate(new Rico.Effect.Position( this.dragElement, this.origPos.x, this.origPos.y),
                      {duration: 200,
                       steps: 20,
                       onFinish : this._doCancelDragProcessing.bind(this) } );
      }

     Event.stopObserving(document.body, "mousemove", this._mouseMove);
     Event.stopObserving(document.body, "mouseup",  this._mouseUp);
   },

   _retTrue: function () {
      return true;
   },

   _completeDropOperation: function(e) {
      if ( this.dragElement != this.currentDragObjects[0].getMouseDownHTMLElement() ) {
         if ( this.dragElement.parentNode != null )
            this.dragElement.parentNode.removeChild(this.dragElement);
      }

      this._deactivateRegisteredDropZones();
      this._endDrag();
      this.clearSelection();
      this.dragElement = null;
      this.currentDragObjectVisible = false;
      this._terminateEvent(e);
   },

   _doCancelDragProcessing: function() {
      this._cancelDrag();

        if ( this.dragElement != this.currentDragObjects[0].getMouseDownHTMLElement() && this.dragElement)
           if ( this.dragElement.parentNode != null )
              this.dragElement.parentNode.removeChild(this.dragElement);


      this._deactivateRegisteredDropZones();
      this.dragElement = null;
      this.currentDragObjectVisible = false;
   },

   _placeDraggableInDropZone: function(e) {
      var foundDropZone = false;
      var n = this.dropZones.length;
      for ( var i = 0 ; i < n ; i++ ) {
         if ( this._mousePointInDropZone( e, this.dropZones[i] ) ) {
            if ( this.dropZones[i].canAccept(this.currentDragObjects) ) {
               this.dropZones[i].hideHover();
               this.dropZones[i].accept(this.currentDragObjects);
               foundDropZone = true;
               break;
            }
         }
      }

      return foundDropZone;
   },

   _cancelDrag: function() {
      for ( var i = 0 ; i < this.currentDragObjects.length ; i++ )
         this.currentDragObjects[i].cancelDrag();
   },

   _endDrag: function() {
      for ( var i = 0 ; i < this.currentDragObjects.length ; i++ )
         this.currentDragObjects[i].endDrag();
   },

   _mousePointInDropZone: function( e, dropZone ) {

      var absoluteRect = dropZone.getAbsoluteRect();

      return e.clientX  > absoluteRect.left + this._leftOffset(e) &&
             e.clientX  < absoluteRect.right + this._leftOffset(e) &&
             e.clientY  > absoluteRect.top + this._topOffset(e)   &&
             e.clientY  < absoluteRect.bottom + this._topOffset(e);
   },

   _addMouseDownHandler: function( aDraggable )
   {
       htmlElement  = aDraggable.getMouseDownHTMLElement();
      if ( htmlElement  != null ) { 
         htmlElement.draggable = aDraggable;
         Event.observe(htmlElement , "mousedown", this._onmousedown.bindAsEventListener(this));
         Event.observe(htmlElement, "mousedown", this._mouseDown);
      }
   },

   _activateRegisteredDropZones: function() {
      var n = this.dropZones.length;
      for ( var i = 0 ; i < n ; i++ ) {
         var dropZone = this.dropZones[i];
         if ( dropZone.canAccept(this.currentDragObjects) )
            dropZone.activate();
      }

      this.activatedDropZones = true;
   },

   _deactivateRegisteredDropZones: function() {
      var n = this.dropZones.length;
      for ( var i = 0 ; i < n ; i++ )
         this.dropZones[i].deactivate();
      this.activatedDropZones = false;
   },

   _onmousedown: function () {
     Event.observe(document.body, "mousemove", this._mouseMove);
     Event.observe(document.body, "mouseup",  this._mouseUp);
   },

   _terminateEvent: function(e) {
      if ( e.stopPropagation != undefined )
         e.stopPropagation();
      else if ( e.cancelBubble != undefined )
         e.cancelBubble = true;

      if ( e.preventDefault != undefined )
         e.preventDefault();
      else
         e.returnValue = false;
   },


	   initializeEventHandlers: function() {
	      if ( typeof document.implementation != "undefined" &&
	         document.implementation.hasFeature("HTML",   "1.0") &&
	         document.implementation.hasFeature("Events", "2.0") &&
	         document.implementation.hasFeature("CSS",    "2.0") ) {
	         document.addEventListener("mouseup",   this._mouseUpHandler.bindAsEventListener(this),  false);
	         document.addEventListener("mousemove", this._mouseMoveHandler.bindAsEventListener(this), false);
	      }
	      else {
	         document.attachEvent( "onmouseup",   this._mouseUpHandler.bindAsEventListener(this) );
	         document.attachEvent( "onmousemove", this._mouseMoveHandler.bindAsEventListener(this) );
	      }
	   }
	}

	var dndMgr = new Rico.DragAndDrop();
	dndMgr.initializeEventHandlers();


//-------------------- ricoDraggable.js
Rico.Draggable = Class.create();

Rico.Draggable.prototype = {

   initialize: function( type, htmlElement ) {
      this.type          = type;
      this.htmlElement   = $(htmlElement);
      this.selected      = false;
   },

   /**
    *   Returns the HTML element that should have a mouse down event
    *   added to it in order to initiate a drag operation
    *
    **/
   getMouseDownHTMLElement: function() {
      return this.htmlElement;
   },

   select: function() {
      this.selected = true;

      if ( this.showingSelected )
         return;

      var htmlElement = this.getMouseDownHTMLElement();

      var color = Rico.Color.createColorFromBackground(htmlElement);
      color.isBright() ? color.darken(0.033) : color.brighten(0.033);

      this.saveBackground = RicoUtil.getElementsComputedStyle(htmlElement, "backgroundColor", "background-color");
//      this.saveBackground = Element.getStyle(htmlElement,'backgroundColor') || Element.getStyle(htmlElement,'background-color')
      htmlElement.style.backgroundColor = color.asHex();
      this.showingSelected = true;
   },

   deselect: function() {
      this.selected = false;
      if ( !this.showingSelected )
         return;

      var htmlElement = this.getMouseDownHTMLElement();

      htmlElement.style.backgroundColor = this.saveBackground;
      this.showingSelected = false;
   },

   isSelected: function() {
      return this.selected;
   },

   startDrag: function() {
   },

   cancelDrag: function() {
   },

   endDrag: function() {
   },

   getSingleObjectDragGUI: function() {
      return this.htmlElement;
   },

   getMultiObjectDragGUI: function( draggables ) {
      return this.htmlElement;
   },

   getDroppedGUI: function() {
      return this.htmlElement;
   },

   toString: function() {
      return this.type + ":" + this.htmlElement + ":";
   }

}


//-------------------- ricoDropzone.js
Rico.Dropzone = Class.create();

Rico.Dropzone.prototype = {

   initialize: function( htmlElement ) {
      this.htmlElement  = $(htmlElement);
      this.absoluteRect = null;
   },

   getHTMLElement: function() {
      return this.htmlElement;
   },

   clearPositionCache: function() {
      this.absoluteRect = null;
   },

   getAbsoluteRect: function() {
      if ( this.absoluteRect == null ) {
         var htmlElement = this.getHTMLElement();
         var pos = RicoUtil.toViewportPosition(htmlElement);

         this.absoluteRect = {
            top:    pos.y,
            left:   pos.x,
            bottom: pos.y + htmlElement.offsetHeight,
            right:  pos.x + htmlElement.offsetWidth
         };
      }
      return this.absoluteRect;
   },

   activate: function() {
      var htmlElement = this.getHTMLElement();
      if (htmlElement == null  || this.showingActive)
         return;

      this.showingActive = true;
      this.saveBackgroundColor = htmlElement.style.backgroundColor;

      var fallbackColor = "#ffea84";
      var currentColor = Rico.Color.createColorFromBackground(htmlElement);
      if ( currentColor == null )
         htmlElement.style.backgroundColor = fallbackColor;
      else {
         currentColor.isBright() ? currentColor.darken(0.2) : currentColor.brighten(0.2);
         htmlElement.style.backgroundColor = currentColor.asHex();
      }
   },

   deactivate: function() {
      var htmlElement = this.getHTMLElement();
      if (htmlElement == null || !this.showingActive)
         return;

      htmlElement.style.backgroundColor = this.saveBackgroundColor;
      this.showingActive = false;
      this.saveBackgroundColor = null;
   },

   showHover: function() {
      var htmlElement = this.getHTMLElement();
      if ( htmlElement == null || this.showingHover )
         return;

      this.saveBorderWidth = htmlElement.style.borderWidth;
      this.saveBorderStyle = htmlElement.style.borderStyle;
      this.saveBorderColor = htmlElement.style.borderColor;

      this.showingHover = true;
      htmlElement.style.borderWidth = "1px";
      htmlElement.style.borderStyle = "solid";
      //htmlElement.style.borderColor = "#ff9900";
      htmlElement.style.borderColor = "#ffff00";
   },

   hideHover: function() {
      var htmlElement = this.getHTMLElement();
      if ( htmlElement == null || !this.showingHover )
         return;

      htmlElement.style.borderWidth = this.saveBorderWidth;
      htmlElement.style.borderStyle = this.saveBorderStyle;
      htmlElement.style.borderColor = this.saveBorderColor;
      this.showingHover = false;
   },

   canAccept: function(draggableObjects) {
      return true;
   },

   accept: function(draggableObjects) {
      var htmlElement = this.getHTMLElement();
      if ( htmlElement == null )
         return;

      n = draggableObjects.length;
      for ( var i = 0 ; i < n ; i++ )
      {
         var theGUI = draggableObjects[i].getDroppedGUI();
/*         if (Element.getStyle(theGUI,'position')=='absolute')*/
         if ( RicoUtil.getElementsComputedStyle( theGUI, "position" ) == "absolute" )
         {
            theGUI.style.position = "static";
            theGUI.style.top = "";
            theGUI.style.top = "";
         }
         htmlElement.appendChild(theGUI);
      }
   }
}

RicoUtil = Object.extend(RicoUtil, {
   getElementsComputedStyle: function ( htmlElement, cssProperty, mozillaEquivalentCSS) {
      if ( arguments.length == 2 )
         mozillaEquivalentCSS = cssProperty;

      var el = $(htmlElement);
      if ( el.currentStyle )
         return el.currentStyle[cssProperty];
      else
         return document.defaultView.getComputedStyle(el, null).getPropertyValue(mozillaEquivalentCSS);
   },

   createXmlDocument : function() {
      if (document.implementation && document.implementation.createDocument) {
         var doc = document.implementation.createDocument("", "", null);

         if (doc.readyState == null) {
            doc.readyState = 1;
            doc.addEventListener("load", function () {
               doc.readyState = 4;
               if (typeof doc.onreadystatechange == "function")
                  doc.onreadystatechange();
            }, false);
         }

         return doc;
      }

      if (window.ActiveXObject)
          return Try.these(
            function() { return new ActiveXObject('MSXML2.DomDocument')   },
            function() { return new ActiveXObject('Microsoft.DomDocument')},
            function() { return new ActiveXObject('MSXML.DomDocument')    },
            function() { return new ActiveXObject('MSXML3.DomDocument')   }
          ) || false;

      return null;
   },

   getContentAsString: function( parentNode ) {
      return parentNode.xml != undefined ? 
         this._getContentAsStringIE(parentNode) :
         this._getContentAsStringMozilla(parentNode);
   },

  _getContentAsStringIE: function(parentNode) {
     var contentStr = "";
     for ( var i = 0 ; i < parentNode.childNodes.length ; i++ ) {
         var n = parentNode.childNodes[i];
         if (n.nodeType == 4) {
             contentStr += n.nodeValue;
         }
         else {
           contentStr += n.xml;
       }
     }
     return contentStr;
  },

  _getContentAsStringMozilla: function(parentNode) {
     var xmlSerializer = new XMLSerializer();
     var contentStr = "";
     for ( var i = 0 ; i < parentNode.childNodes.length ; i++ ) {
          var n = parentNode.childNodes[i];
          if (n.nodeType == 4) { // CDATA node
              contentStr += n.nodeValue;
          }
          else {
            contentStr += xmlSerializer.serializeToString(n);
        }
     }
     return contentStr;
  },

   toViewportPosition: function(element) {
      return this._toAbsolute(element,true);
   },

   toDocumentPosition: function(element) {
      return this._toAbsolute(element,false);
   },

   /**
    *  Compute the elements position in terms of the window viewport
    *  so that it can be compared to the position of the mouse (dnd)
    *  This is additions of all the offsetTop,offsetLeft values up the
    *  offsetParent hierarchy, ...taking into account any scrollTop,
    *  scrollLeft values along the way...
    *
    * IE has a bug reporting a correct offsetLeft of elements within a
    * a relatively positioned parent!!!
    **/
   _toAbsolute: function(element,accountForDocScroll) {

      if ( navigator.userAgent.toLowerCase().indexOf("msie") == -1 )
         return this._toAbsoluteMozilla(element,accountForDocScroll);

      var x = 0;
      var y = 0;
      var parent = element;
      while ( parent ) {

         var borderXOffset = 0;
         var borderYOffset = 0;
         if ( parent != element ) {
            var borderXOffset = parseInt(this.getElementsComputedStyle(parent, "borderLeftWidth" ));
            var borderYOffset = parseInt(this.getElementsComputedStyle(parent, "borderTopWidth" ));
            borderXOffset = isNaN(borderXOffset) ? 0 : borderXOffset;
            borderYOffset = isNaN(borderYOffset) ? 0 : borderYOffset;
         }

         x += parent.offsetLeft - parent.scrollLeft + borderXOffset;
         y += parent.offsetTop - parent.scrollTop + borderYOffset;
         parent = parent.offsetParent;
      }

      if ( accountForDocScroll ) {
         x -= this.docScrollLeft();
         y -= this.docScrollTop();
      }

      return { x:x, y:y };
   },

   /**
    *  Mozilla did not report all of the parents up the hierarchy via the
    *  offsetParent property that IE did.  So for the calculation of the
    *  offsets we use the offsetParent property, but for the calculation of
    *  the scrollTop/scrollLeft adjustments we navigate up via the parentNode
    *  property instead so as to get the scroll offsets...
    *
    **/
   _toAbsoluteMozilla: function(element,accountForDocScroll) {
      var x = 0;
      var y = 0;
      var parent = element;
      while ( parent ) {
         x += parent.offsetLeft;
         y += parent.offsetTop;
         parent = parent.offsetParent;
      }

      parent = element;
      while ( parent &&
              parent != document.body &&
              parent != document.documentElement ) {
         if ( parent.scrollLeft  )
            x -= parent.scrollLeft;
         if ( parent.scrollTop )
            y -= parent.scrollTop;
         parent = parent.parentNode;
      }

      if ( accountForDocScroll ) {
         x -= this.docScrollLeft();
         y -= this.docScrollTop();
      }

      return { x:x, y:y };
   },

   docScrollLeft: function() {
      if ( window.pageXOffset )
         return window.pageXOffset;
      else if ( document.documentElement && document.documentElement.scrollLeft )
         return document.documentElement.scrollLeft;
      else if ( document.body )
         return document.body.scrollLeft;
      else
         return 0;
   },

   docScrollTop: function() {
      if ( window.pageYOffset )
         return window.pageYOffset;
      else if ( document.documentElement && document.documentElement.scrollTop )
         return document.documentElement.scrollTop;
      else if ( document.body )
         return document.body.scrollTop;
      else
         return 0;
   }
});

Rico.includeLoaded('ricoDragDrop.js');
