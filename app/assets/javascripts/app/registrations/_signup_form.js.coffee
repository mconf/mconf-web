class mconf.SignupForm
  @setup: ->
    $fullname = $("[name='user[profile_attributes][full_name]']")
    $username = $("[name='user[username]']")
    $username.attr "value", mconf.Base.stringToSlug($fullname.val())
    $fullname.on "input keyup", ->
      $username.attr "value", mconf.Base.stringToSlug($fullname.val())
