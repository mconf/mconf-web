#= require "../users/new"

$ ->
  if isOnPage 'manage', 'users'
    mconf.Resources.addToBind ->
      mconf.Users.New.bind()
