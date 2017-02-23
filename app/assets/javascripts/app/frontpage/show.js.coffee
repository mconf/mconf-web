#= require "../registrations/_signup_form"
#= require "../application/certificate_authentication"

$ ->
  if isOnPage 'frontpage', 'show'
    mconf.SignupForm.setup()

    mconf.CertificateAuthentication.bind()
