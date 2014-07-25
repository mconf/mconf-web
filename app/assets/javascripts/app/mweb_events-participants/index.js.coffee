#= require "../mweb_events-events/_invite"

$ ->
  if isOnPage 'mweb_events-participants', 'index'

    # set to rebind the invitation view when the resources are rebound
    mconf.Resources.addToBind ->
      mconf.MwebEventsEvents.Invitation.bind()
