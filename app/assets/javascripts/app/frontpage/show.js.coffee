#= require "../registrations/_signup_form"

$ ->
  if isOnPage 'frontpage', 'show'
    window.mconf.SignupForm.setup()
