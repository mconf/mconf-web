#= require "../my/_edit_room"

$ ->
  if isOnPage 'my', 'activity'

    # set to rebind things when the resources are rebound
    mconf.Resources.addToBind ->
      mconf.EditRoom.setup()