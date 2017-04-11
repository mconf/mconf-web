mconf.Users or= {}

class mconf.Users.New

  @bind: ->
    @unbind()
    $fullname = $("#user_profile_attributes_full_name:not(.disabled)")
    $username = $("#user_username:not(.disabled)")
    $username.attr "value", mconf.Base.stringToSlug($fullname.val())
    $fullname.on "input.mconfUsersNew keyup.mconfUsersNew", ->
      $username.attr "value", mconf.Base.stringToSlug($fullname.val())

  @unbind: ->
    $fullname = $("#user_profile_attributes_full_name:not(.disabled)")
    $fullname.off "input.mconfUsersNew"
    $fullname.off "keyup.mconfUsersNew"
