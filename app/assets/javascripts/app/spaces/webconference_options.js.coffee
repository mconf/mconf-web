$ ->
  if isOnPage 'spaces', 'webconference_options'

    visibilityChanged(this)
    console.log("hu")
    $('#space_bigbluebutton_room_attributes_private').on 'change', ->
      visibilityChanged(this)

visibilityChanged = (el) ->
  if $('#space_bigbluebutton_room_attributes_private').is(":checked")
    $('#attendee-key').show()
  else
    $('#attendee-key').hide()
