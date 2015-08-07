$ ->
  if isOnPage 'profiles', 'edit|update'

    uploaderCallbacks =
      onComplete: mconf.Crop.onUploadComplete

    mconf.Uploader.bind
      callbacks: uploaderCallbacks

    # Hide vcard form when we have javascript
    $(".profile_vcard input").hide()
    $(".profile_vcard label").hide()
    $("#profile-vcard-submit").hide()

    # Auto submit vcard form
    $("#profile_vcard").change ->
      $(this).closest('form').submit()
