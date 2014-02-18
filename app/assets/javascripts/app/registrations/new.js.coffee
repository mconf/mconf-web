#= require "../registrations/_signup_form"

$ ->
  if isOnPage 'registrations', 'new'
    mconf.SignupForm.setup()
