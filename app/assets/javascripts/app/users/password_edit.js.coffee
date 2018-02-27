#= require jquery/jquery.maskedinput

submitSelector = 'input[type=\'submit\']'

$ ->
  if isOnPage 'users', 'password_edit|update'
    console.log("porra")
    $('#user_current_password').on "keydown keyup", =>
      enableSave()
    $('#user_password').on "keydown keyup", =>
      enableSave()
    $('#user_password_confirmation').on "keydown keyup", =>
      enableSave()

enableSave = ->
  console.log(888)
  hasPrevPassword = $('#user_current_password').val()?.length > 0
  hasNewPassword = $('#user_password').val()?.length > 0
  hasConfirmationPassword = $('#user_password_confirmation').val()?.length > 0

  if hasPrevPassword and hasNewPassword and hasConfirmationPassword
    $(submitSelector).removeAttr('disabled')
  else
    $(submitSelector).attr('disabled','disabled')
