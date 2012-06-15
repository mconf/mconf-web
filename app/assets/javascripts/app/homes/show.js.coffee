#= require ../users/edit_bbb_room

# $ ->
#   if isOnPage 'homes', 'show'

$ ->

  $(document).trigger('connect',{login: "USER_LOGIN@CHAT.HOST", password: "USER PASSWORD", name: "USER FULL NAME", url: "USER BBB ROOM"})