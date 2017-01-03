$ ->
  if isOnPage 'profiles', 'edit|update'

    uploaderCallbacks =
      onComplete: mconf.Crop.onUploadComplete

    mconf.Uploader.bind
      callbacks: uploaderCallbacks

    # Auto submit vcard form
    $("#profile_vcard").change ->
      $(this).closest('form').submit()
