#= require "../custom_bigbluebutton_rooms/_join_options"

$ ->
  if isOnPage 'homes', 'show'

    # Almost the same that is done in spaces/_sidebar

    # set to rebind JoinOptions when the resources are rebound
    mconf.Resources.addToBind ->
      mconf.CustomBigbluebuttonRooms.JoinOptions.bind()

    # check the inputs for the first time when the modal is opened
    $(document).on "modal-shown", ->
      mconf.CustomBigbluebuttonRooms.JoinOptions.verifyInputs()

    # this modal binds some things in the modal using "global" selectors such as ".modal"
    # so we make sure we unbind everything when the modal is closed
    $("#webconference-room .webconf-join-group").on "modal-hidden", ->
      mconf.CustomBigbluebuttonRooms.JoinOptions.unbind()
