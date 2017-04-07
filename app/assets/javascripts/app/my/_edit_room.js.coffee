class mconf.EditRoom
  @setup: ->
    visibilityChanged(this)
    $('#bigbluebutton_room_private').on 'change', ->
      visibilityChanged(this)

visibilityChanged = (el) ->
    if $('#bigbluebutton_room_private').is(":checked") 
      $('.bigbluebutton_room_attendee_key').show()
    else
      $('.bigbluebutton_room_attendee_key').hide()
