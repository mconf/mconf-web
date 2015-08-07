$ ->
  if isOnPage 'spaces', 'edit'
    updatePasswords($('input#space_public').is(':checked'))
    $('input#space_public').on 'click', -> updatePasswords($(this).is(':checked'))

    uploaderCallbacks =
      onComplete: (id, name, response) ->

        if response.success
          # show the crop modal if image is not too small
          if !response.small_image
            $.get response.redirect_url, (data) ->
              mconf.Modal.showWindow
                data: data
          else
            location.reload(true)

    mconf.Uploader.bind
      callbacks: uploaderCallbacks

updatePasswords = (checked) ->
  $('#space_bigbluebutton_room_attributes_attendee_key').prop('disabled', checked)
  $('#space_bigbluebutton_room_attributes_moderator_key').prop('disabled', checked)
