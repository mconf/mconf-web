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
          $(this).show();
      }else{
          $(this).hide("fast");
      }
      });
    $(".user_checkbox input:checked").each(function(){
      $(this).parent().show();
    });
  };

  $.extend($.fn, {
    allocate: function() { 
        if($(this).is(":checked")){
          $("#selected_users").append($(this).parent().clone()).hide().show("fast");
          $(this).parent().remove();
        }else{
          $("#unselected_users").append($(this).parent().clone()).hide().show("fast");
          $(this).parent().remove();
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