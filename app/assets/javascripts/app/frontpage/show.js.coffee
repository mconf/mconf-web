#= require "../registrations/_signup_form"

$ ->
  if isOnPage 'frontpage', 'show'
    mconf.SignupForm.setup()
