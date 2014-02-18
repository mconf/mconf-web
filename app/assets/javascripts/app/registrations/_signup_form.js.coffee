class mconf.SignupForm
  @setup: ->
    $fullname = $("#user__full_name")
    $username = $("#user_username")
    $username.attr "value", mconf.Base.stringToSlug($fullname.val())
    $fullname.on "input keyup", () ->
      $username.attr "value", mconf.Base.stringToSlug($fullname.val())
