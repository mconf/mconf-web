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
     image: "/images/choose-file.gif",
     imageheight : 22,
     imagewidth : 80,
     width : 115,
  });
};