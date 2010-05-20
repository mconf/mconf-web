/*!
 * jQuery VCC: jQuery Plugin for VCC
 * 
 * This plugin includes:
 * - $.vcc.scrollTo(anchorSelector)
 */

(function($, window){

// Defining namespace for VCC plugin
var jq_vcc = $.vcc = $.vcc || {};


//
// START: $.vcc.scrollTo feature
//
function animateScroll(destinationTop) {
  $('html,body').animate({scrollTop: destinationTop}, 1000);
};

jq_vcc.iframeScrollTo = function(anchorSelector) {
  var destinationTop = $(iframeSelector).contents().find(anchorSelector).offset().top;
  animateScroll(destinationTop);
};

jq_vcc.directScrollTo = function(anchorSelector) {
  var destinationTop = $(anchorSelector).offset().top;
  animateScroll(destinationTop);
};

jq_vcc.scrollTo = function(anchorSelector) {
  // Detect if we are into a iframe or not
  if ( window == window.top) {
    // If we are NOT into a iframe...
    jq_vcc.directScrollTo(anchorSelector);
  } else {
    // If we are into a iframe...
    parent.jQuery.jq_vcc.iframeScrollTo(anchorSelector);
  }
};
//
// END: $.vcc.scrollTo feature
//

//
// START: $.vcc.newFeature
//
// new feature code goes here...
//
// END: $.vcc.newFeature
//

})(jQuery, this);