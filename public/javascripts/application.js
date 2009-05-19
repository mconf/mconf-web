/* jQuery.ajaxSetup({ 
  'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
})
*/

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
 *  Input files style
 */
 
style_file_input = function(){
  $("input[type=file]").filestyle({ 
     image: "/images/buttons/browse.png",
     imageheight : 23,
     imagewidth : 63,
     width : 115,
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
  $("#embed").css({height:windowHeight,width:"100%"})
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
};
