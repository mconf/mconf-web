  var speed = "normal"
	
	selected_users_check = function(){
    if($(".user_checkbox input:checked").length > 0){
      $("#selected_users label:first").show();
    }else{
      $("#selected_users label:first").hide();
    }
  };
  
  filter_user = function(filter_text){
		$("#unselected_users .user_checkbox").each(function() {
        if($(this).find("label").text().toLowerCase().search(filter_text)>=0){
          $(this).show(speed);
      }else{
          $(this).hide(speed);
      }
      });
    $(".user_checkbox input:checked").each(function(){
      $(this).parent().show();
    });
  };

  $.extend($.fn, {
    allocate: function() {
        if($(this).is(":checked")){
					if ($(this).parents("#selected_users").length == 0){
						var cb = $(this).parent().clone().hide();
						$("#selected_users").append(cb);
						$(this).parent().hide(speed, function () {
              $(this).remove();
            });
            cb.show(speed);
					}	
        }else{
				  if ($(this).parents("#unselected_users").length == 0) {
						var cb = $(this).parent().clone().hide();
		  	    $("#unselected_users").append(cb);
						$(this).parent().hide(speed, function () {
              $(this).remove();
            });
		  	    cb.show(speed);
		      }
        }
      }
  });
  
  $(function(){
    $("#user_filter").show();
    selected_users_check();
    $(".user_checkbox input").each(function() {
      $(this).allocate();
    });
  });
  
  $(".user_checkbox input").livequery('click', function() {
    selected_users_check();
    $(this).allocate();
  }); 


  $("#user_selector").livequery('keyup', function() {
    var filter_text = this.value.toLowerCase();
    filter_user(filter_text);
  });