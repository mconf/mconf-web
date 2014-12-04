$ ->
  if isOnPage 'profiles', 'edit|update'

    uploaderCallbacks =
      onComplete: (id, name, response) ->
        if response.success
          $.get response.redirect_url, (data) ->
            # show the crop modal
            mconf.Modal.showWindow
              data: data

    mconf.Uploader.bind
      callbacks: uploaderCallbacks

    # Hide vcard form when we have javascript
    $(".profile_vcard input").hide()
    $(".profile_vcard label").hide()
    $("#profile-vcard-submit").hide()

    # Auto submit vcard form
    $("#profile_vcard").change ->
      $(this).closest('form').submit()
