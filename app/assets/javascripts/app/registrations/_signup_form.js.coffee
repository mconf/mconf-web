class mconf.SignupForm
  @setup: ->
    $fullname = $("#user__full_name:not(.disabled)")
    $username = $("#user_username:not(.disabled)")
    $username.attr "value", mconf.Base.stringToSlug($fullname.val())
    $fullname.on "input keyup", () ->
      $username.attr "value", mconf.Base.stringToSlug($fullname.val())
