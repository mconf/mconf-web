#= require "../join_requests/invite"

$ ->
  if isOnPage 'join_requests', 'admissions'

    # set to rebind things when the resources are rebound
    mconf.Resources.addToBind ->
      mconf.JoinRequests.Invite.bind()

    # this modal binds some things in the modal using "global" selectors such as ".modal"
    # so we make sure we unbind everything when the modal is closed
    $("#webconference-room .webconf-join-group").on "modal-hidden", ->
      mconf.JoinRequests.Invite.unbind()