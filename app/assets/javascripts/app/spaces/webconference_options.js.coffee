$ ->
  if isOnPage 'spaces', 'webconference_options'

    visibilityChanged(this)
    $('#space_bigbluebutton_room_attributes_private').on 'change', ->
      visibilityChanged(this)

visibilityChanged = (el) ->
  if $('#space_bigbluebutton_room_attributes_private').is(":checked")
    $('#attendee-key input').attr('disabled', null)
    $('#attendee-key').show()
  else
    $('#attendee-key input').attr('disabled', true)
    $('#attendee-key').hide()
