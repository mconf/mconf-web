#= require ../users/edit_bbb_room

window.onbeforeunload = ->
  $(document).trigger("disconnect")
  return

$ ->
  if isOnPage 'homes', 'show'
    if chat_enabled
      $(document).trigger 'connect',
        domain: domain
        login: login + domain
        password: cookie
        name: name
        url: url
        xmpp_server: xmpp_server
