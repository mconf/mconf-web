#= require ../users/_edit_bbb_room

$ ->
  if isOnPage 'homes', 'show'
    mconf.EditBbbRoom.setup()
