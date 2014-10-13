#= require "../registrations/_signup_form"

$ ->
  if isOnPage 'manage', 'users'
    $(document).on 'shown.bs.modal', ->
      mconf.SignupForm.setup()
