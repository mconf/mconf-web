   #= require ../users/edit_bbb_room

# $ ->
#   if isOnPage 'homes', 'show'

$ ->
  $(document).trigger('connect',{domain: domain, login: login+domain, password: cookie, name: name, url: url, xmpp_server: xmpp_server}) if chat_enabled