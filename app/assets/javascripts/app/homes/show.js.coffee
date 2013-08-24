#= require "../custom_bigbluebutton_rooms/_join_options"

$ ->
  if isOnPage 'homes', 'show'
    mconf.CustomBigbluebuttonRooms.JoinOptions.setup()
    $(document).on "modal-after-update-markup", ->
      mconf.CustomBigbluebuttonRooms.JoinOptions.verifyInputs()
