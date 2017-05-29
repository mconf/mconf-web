mconf.Users or= {}

class mconf.Users.New

  @bind: ->
    @unbind()
    $fullname = $("#user_profile_attributes_full_name:not(.disabled)")
    $username = $("#user_username:not(.disabled)")
    $username.attr "value", mconf.Base.stringToSlug($username.val(), true)
    $username.on "input", () ->
      $username.val(mconf.Base.stringToSlug($username.val(), true))
    $username.on "blur", () ->
      $username.val(mconf.Base.stringToSlug($username.val(), false))
    $fullname.on "input.mconfUsersNew keyup.mconfUsersNew", ->
      $username.attr "value", mconf.Base.stringToSlug($fullname.val())

  @unbind: ->
    $fullname = $("#user_profile_attributes_full_name:not(.disabled)")
    $fullname.off "input.mconfUsersNew"
    $fullname.off "keyup.mconfUsersNew"
