$ ->
  if isOnPage 'profiles', 'edit|update'

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

    # Hide vcard form when we have javascript
    $(".profile_vcard input").hide()
    $(".profile_vcard label").hide()
    $("#profile-vcard-submit").hide()

    # Auto submit vcard form
    $("#profile_vcard").change ->
      $(this).closest('form').submit()
