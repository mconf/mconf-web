$ ->
  if isOnPage 'spaces', 'edit'
    updatePasswords($('input#space_public').is(':checked'))
    $('input#space_public').on 'click', -> updatePasswords($(this).is(':checked'))

    uploaderCallbacks =
      onComplete: mconf.Crop.onUploadComplete

    mconf.Uploader.bind
      callbacks: uploaderCallbacks

updatePasswords = (checked) ->
  $('#space_bigbluebutton_room_attributes_attendee_key').prop('disabled', checked)
  $('#space_bigbluebutton_room_attributes_moderator_key').prop('disabled', checked)
