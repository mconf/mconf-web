# There are things in the header that are used in several pages in this controller

#= require "../custom_bigbluebutton_rooms/_invitation_form"

$ ->
  if isOnPage 'my', 'home'

    # set to rebind JoinOptions when the resources are rebound
    mconf.Resources.addToBind ->
      mconf.CustomBigbluebuttonRooms.Invitation.bind()

    # this modal binds some things in the modal using "global" selectors such as ".modal"
    # so we make sure we unbind everything when the modal is closed
    $("#webconference-room .webconf-join-group").on "modal-hidden", ->
      mconf.CustomBigbluebuttonRooms.Invitation.unbind()
