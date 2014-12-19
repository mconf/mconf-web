mconf.Users or= {}

class mconf.Users.New

  @bind: ->
    @unbind()
    $fullname = $("#user__full_name")
    $username = $("#user_username")
    $username.attr "value", mconf.Base.stringToSlug($fullname.val())
    $fullname.on "input.mconfUsersNew keyup.mconfUsersNew", ->
      $username.attr "value", mconf.Base.stringToSlug($fullname.val())

  @unbind: ->
    $fullname = $("#user__full_name")
    $fullname.off "input.mconfUsersNew"
    $fullname.off "keyup.mconfUsersNew"
