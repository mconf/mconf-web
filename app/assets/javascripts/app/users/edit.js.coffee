#= require jquery/jquery.maskedinput

$ ->
  if isOnPage 'users', 'edit|update'

    $phone = $('#user_profile_attributes_phone:not(disabled)')
    $phone.mask("(99) 99999-999?9")

    $zipcode = $('#user_profile_attributes_zipcode:not(disabled)')
    $zipcode.mask("99999-999");

    uploaderCallbacks =
      onComplete: mconf.Crop.onUploadComplete

    if $('.upload-button').length > 0
      mconf.Uploader.bind
        callbacks: uploaderCallbacks

    $("#user_timezone").select2
      minimumInputLength: 0
      width: '100%'
