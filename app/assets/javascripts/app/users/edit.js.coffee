$ ->
  if isOnPage 'users', 'edit|update'

    uploaderCallbacks =
      onComplete: mconf.Crop.onUploadComplete
    mconf.Uploader.bind
      callbacks: uploaderCallbacks

    $("#user_timezone").select2
      minimumInputLength: 0
      width: '100%'
