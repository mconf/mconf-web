#= require "../registrations/_signup_form"

$ ->
  if isOnPage 'registrations', 'new|create'
    mconf.SignupForm.setup()
