$ ->
  if isOnPage 'spaces', 'edit'
    updatePasswords($('input#space_public').is(':checked'))
    $('input#space_public').on 'click', -> updatePasswords($(this).is(':checked'))

updatePasswords = (checked) ->
  $('#space_bigbluebutton_room_attributes_attendee_password').prop('disabled', checked)
  $('#space_bigbluebutton_room_attributes_moderator_password').prop('disabled', checked)
