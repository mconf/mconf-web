#= require "../events/_invite"

$ ->
  if isOnPage 'participants', 'index'

    # set to rebind the invitation view when the resources are rebound
    mconf.Resources.addToBind ->
      mconf.MwebEventsEvents.Invitation.bind()
