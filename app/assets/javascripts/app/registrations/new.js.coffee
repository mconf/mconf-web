#= require "../registrations/_signup_form"

$ ->
  if isOnPage 'registrations', 'new|create'
    window.mconf.SignupForm.setup()
