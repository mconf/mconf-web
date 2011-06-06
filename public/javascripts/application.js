/* jQuery.ajaxSetup({ 
  'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
})
*/

function changeInputTextType (id, type) {
  marker = $('<span />').insertBefore(id);
  $(id).detach().attr('type', type).insertAfter(marker);
  marker.remove();
}

jQuery.fn.submitWithAjax = function() {
  this.submit(function() {
    $.post(this.action, $(this).serialize(), null, "script");
    return false;
  })
  return this;
};

/*
 * Post ajax submit form
 */

jQuery.fn.postsForm = function(route){
	this.ajaxForm({
		dataType: 'script',
		success: function(data){
			if (data == "") {
				window.location = route;
			}
		}
	});
};

/*
 * Link with ajax the same url
 */

jQuery.fn.ajaxLink = function(){
  this.click(function(data) {
    $.get(this.href,{},function(data){
		  eval(data);
	  },"script");
    return false;
  })
  return this;
};

/*
 *  Input files style
 */
 
style_file_input = function(){
  $("input[type=file]")
	  .filter(function(index) {
      if ($(this).css("opacity") != "0") return true;
    }).filestyle({ 
        image: "/images/buttons/browse.png",
        imageheight : 23,
        imagewidth : 63,
        width : 115
      });
};

/*
 * Fullscreen online conference
 */

setFullScreen = function(){

	var windowHeight = window.innerHeight ? window.innerHeight : document.documentElement.clientHeight ? document.documentElement.clientHeight : document.body.clientHeight;
          
  $("#header").hide();
  $("#selector").hide();
  $("#menu").hide();
  $("#global-wrapper").hide();
  $("#footer").hide();
  $("#space").css({height:"100%",width:"100%"});
  $("#content").css({height:"100%",width:"100%"});
  $("#main").css({height:"100%",width:"100%"});
  $("#embed").css({height:windowHeight,width:"100%"});
	$("div").css({padding:"0",margin:"0"});
};

unsetFullScreen = function(){
  $("#header").show();
  $("#selector").show();
  $("#menu").show();
  $("#global-wrapper").show();
  $("#footer").show();
  $("#space").css({height:"",width:""});
  $("#content").css({height:"",width:""});
  $("#main").css({height:"",width:""});
  $("#embed").css({height:"",width:""});
	$("div").css({padding:"",margin:""});
};
