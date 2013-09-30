# There are things in the header that are used in several pages in this controller

#= require "../custom_bigbluebutton_rooms/_join_options"
#= require "../invites/_invite_room"

$ ->
  if isOnPage 'my', 'home'

    # set to rebind JoinOptions when the resources are rebound
    mconf.Resources.addToBind ->
      mconf.CustomBigbluebuttonRooms.JoinOptions.bind()
      mconf.Invites.InviteRoom.bind()

    # check the inputs for the first time when the modal is opened
    $(document).on "modal-shown", ->
      mconf.CustomBigbluebuttonRooms.JoinOptions.verifyInputs()

    # this modal binds some things in the modal using "global" selectors such as ".modal"
    # so we make sure we unbind everything when the modal is closed
    $("#webconference-room .webconf-join-group").on "modal-hidden", ->
      mconf.CustomBigbluebuttonRooms.JoinOptions.unbind()
      mconf.Invites.InviteRoom.unbind()
