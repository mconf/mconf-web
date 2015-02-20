#= require "../application/user_select"

$ ->
  if isOnPage 'mweb_events-events', 'user_permissions'
    mconf.UserSelect.bind('#users')
