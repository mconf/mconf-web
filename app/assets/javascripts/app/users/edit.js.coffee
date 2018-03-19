#= require jquery/jquery.maskedinput

$ ->
  if isOnPage 'users', 'edit|update'

    $cpfcnpj = $('#user_profile_attributes_cpf_cnpj:not(disabled)')
    $cpfcnpj.mask("99999999999?999",{placeholder:" "})

    $phone = $('#user_profile_attributes_phone:not(disabled)')
    $phone.mask("(99) 99999-999?9")

    $zipcode = $('#user_profile_attributes_zipcode:not(disabled)')
    $zipcode.mask("99999-999");

    uploaderCallbacks =
      onComplete: mconf.Crop.onUploadComplete

    mconf.Uploader.bind
      callbacks: uploaderCallbacks

    $("#user_timezone").select2
      minimumInputLength: 0
      width: '100%'
