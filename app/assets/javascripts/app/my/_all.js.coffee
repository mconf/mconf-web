# There are things in the header that are used in several pages in this controller

#= require "../custom_bigbluebutton_rooms/_invitation_form"
#= require "../custom_bigbluebutton_rooms/user_edit"

$ ->
  if isOnPage 'my', 'home'

    # set to rebind things when the resources are rebound
    mconf.Resources.addToBind ->
      mconf.CustomBigbluebuttonRooms.Invitation.bind()
      mconf.UserEdit.setup()

    # this modal binds some things in the modal using "global" selectors such as ".modal"
    # so we make sure we unbind everything when the modal is closed
    $("#webconference-room .webconf-join-group").on "modal-hidden", ->
      mconf.CustomBigbluebuttonRooms.Invitation.unbind()
