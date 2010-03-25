/* 
*  Mouse wheel support for OS X - implemented in javascript because Adobe
*  hasn't implemented it in the mac version of Flash Player  >:(
*  
*  Seems to work on Firefox 2 and Safari 2.
*  
*  Copyright (c) 2007 Ali Rantakari ( http://hasseg.org/blog )
*  
*  Feel free to use, given that this notice stays intact
*  
*/




var mw_keepDeltaAtPlusMinusThree = false; // let's not allow other deltas than +/- 3 because that's what flash player does

var mw_container = null;



// this function courtesy of the Adobe peepz
function thisMovie(movieName) {
    if (navigator.appName.indexOf("Microsoft") != -1) {
        return window[movieName];
    } else {
        return document[movieName];
    }
}




function mw_initialize() {
	// initialize mouse wheel capturing:
	mw_container = document.getElementById(mw_flashContainerId);
	if (mw_container != null) {
		if (mw_container.addEventListener) mw_container.addEventListener('DOMMouseScroll', mw_onWheelHandler, false); // Firefox
		mw_container.onmousewheel = mw_onWheelHandler; // Safari
	}else{
		alert("osxmousewheel: can not find flash container div element");
	}
}


// Handler for mouse wheel event:
function mw_onWheelHandler(event){
	var delta = 0;
	if (!event) event = window.event;
	if (event.wheelDelta) {
		// Safari
		delta = event.wheelDelta/120;
		if (window.opera) delta = -delta;
	} else if (event.detail) {
		// Firefox
		delta = -event.detail*3;
	}
	
	if (mw_keepDeltaAtPlusMinusThree) {
		if (delta > 0) delta = 3;
		else if (delta == 0) delta = 0;
		else delta = -3;
	}
	
	if (delta) {
		// handle mouse events here:
		
		var thisMouse;
		if ((navigator.userAgent.indexOf('Firefox') != -1) || (navigator.userAgent.indexOf('Camino') != -1)) thisMouse = {x:event.layerX, y:event.layerY};
		else if (navigator.userAgent.indexOf('Safari') != -1) thisMouse = {x:event.offsetX, y:event.offsetY};
		else if (navigator.userAgent.indexOf('Opera') != -1) thisMouse = {x:event.offsetX, y:event.offsetY};
		else thisMouse = {x:event.offsetX, y:event.offsetY};
		
		if (thisMovie(mw_flashMovieId).dispatchExternalMouseWheelEvent) thisMovie(mw_flashMovieId).dispatchExternalMouseWheelEvent(delta, thisMouse.x, thisMouse.y);
		else alert("osxmousewheel: ExternalInferface function dispatchExternalMouseWheelEvent not found");
		
	};
	
	// Prevent default actions caused by mouse wheel.
	if (event.preventDefault) event.preventDefault();
	event.returnValue = false;
}


