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