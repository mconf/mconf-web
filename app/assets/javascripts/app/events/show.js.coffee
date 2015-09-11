#= require "./_invite"

$ ->
  if isOnPage 'mweb_events-events', 'show'

    # set to rebind the invitation view when the resources are rebound
    mconf.Resources.addToBind ->
      mconf.MwebEventsEvents.Invitation.bind()
