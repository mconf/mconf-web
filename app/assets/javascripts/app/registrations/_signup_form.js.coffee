class mconf.SignupForm
  @setup: ->
    $fullname = $("[name='user[profile_attributes][full_name]']")
    $username = $("#user_username:not(.disabled)")
    $username.attr "value", mconf.Base.stringToSlug($username.val(), true)
    $username.on "input", () ->
      $username.val(mconf.Base.stringToSlug($username.val(), true))
    $username.on "blur", () ->
      $username.val(mconf.Base.stringToSlug($username.val(), false))
    $fullname.on "input keyup", ->
      $username.attr "value", mconf.Base.stringToSlug($fullname.val())
