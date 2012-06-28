   #= require ../users/edit_bbb_room

# $ ->
#   if isOnPage 'homes', 'show'

$ ->

  $(document).trigger('connect',{login: login, password: cookie, name: name, url: url})