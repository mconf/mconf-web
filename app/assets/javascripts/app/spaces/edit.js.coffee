$ ->
  if isOnPage 'spaces', 'edit'
    updatePasswords($('input#space_public').is(':checked'))
    $('input#space_public').on 'click', -> updatePasswords($(this).is(':checked'))

    uploaderCallbacks =
      onComplete: (id, name, response) ->
        if response.success
          $.get response.redirect_url, (data) ->
            # show the crop modal
            mconf.Modal.showWindow
              data: data

    mconf.Uploader.bind
      callbacks: uploaderCallbacks

updatePasswords = (checked) ->
  $('#space_bigbluebutton_room_attributes_attendee_password').prop('disabled', checked)
  $('#space_bigbluebutton_room_attributes_moderator_password').prop('disabled', checked)
