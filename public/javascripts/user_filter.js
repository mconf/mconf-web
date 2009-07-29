  var speed = "slow"
  
	clear_users = function(){
		$("#unselected_users .user_checkbox").hide();
    $("#show_all_users_link").show();
	};
	
  show_all_users = function(){
    $(".user_checkbox").show(speed);
    $("#show_all_users_link").hide();
  };
	
  select_all_users = function(){
    $("#unselected_users .user_checkbox input").each(function() {
        $(this).attr('checked', true);
        $(this).allocate();
    });
    $("#show_all_users_link").hide();
    $("#select_all_users_link").hide();
    $("#deselect_all_users_link").show();
  };
  
  deselect_all_users = function(){
    $("#selected_users .user_checkbox input").each(function() {
        $(this).attr('checked', false);
        $(this).allocate();
    });
    $("#show_all_users_link").show();
    $("#select_all_users_link").show();
    $("#deselect_all_users_link").hide();
    clear_users();
  }; 
  
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
		$("#user_filter").append("<a href=\"javascript:show_all_users()\" id=\"show_all_users_link\">Show all users</a>  <a href=\"javascript:select_all_users()\" id=\"select_all_users_link\">Select all users</a>");
		$("#user_filter").append("<a href=\"javascript:hide_all_users()\" id=\"hide_all_users_link\">Hide all users</a>  <a href=\"javascript:deselect_all_users()\" id=\"deselect_all_users_link\">Deselect all users</a>");
		$("#hide_all_users_link").hide();
    $("#deselect_all_users_link").hide();
		clear_users();
  });
  
  $(".user_checkbox input").livequery('click', function() {
    selected_users_check();
    $(this).allocate();
  }); 


  $("#user_selector").livequery('keyup', function() {
		if (this.value == ""){
			clear_users();
		}else{
			var filter_text = this.value.toLowerCase();
	    filter_user(filter_text);
			$("#show_all_users_link").hide();
		}
  });