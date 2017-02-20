#= require "../application/certificate_authentication"

$ ->
  if isOnPage 'sessions', 'new|create'
    mconf.CertificateAuthentication.bind()
