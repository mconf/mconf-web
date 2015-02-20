#= require "../mweb_events-events/_invite"
#= require "../application/user_select"

$ ->
  if isOnPage 'mweb_events-participants', 'index'

    # set to rebind the invitation view when the resources are rebound
    mconf.Resources.addToBind ->
      mconf.UserSelect.bind('#users')
      mconf.MwebEventsEvents.Invitation.bind()
