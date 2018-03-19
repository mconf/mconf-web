#= require jquery/jquery.maskedinput

$ ->
  if isOnPage 'users', 'edit_data|update'

    uploaderCallbacks =
      onComplete: mconf.Crop.onUploadComplete

    mconf.Uploader.bind
      callbacks: uploaderCallbacks
