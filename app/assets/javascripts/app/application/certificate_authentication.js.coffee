class mconf.CertificateAuthentication

  @bind: ->
    $('.certificate-auth-trigger').off 'click.mconfCertificateAuthentication'
    $('.certificate-auth-trigger').on 'click.mconfCertificateAuthentication', (e) ->
      e.preventDefault()

      $.ajax $(this).attr('href'),
        contentType: 'application/json'
        complete: (xhr) ->

          # the expected response, a json with info about success or error
          if xhr.status == 200
            response = xhr.responseJSON

            if response.result == true
              window.location = response.redirect_to
            else
              mconf.Notification.addAndShow('error', response.error)

          # something went wrong, show a generic error
          else
            mconf.Notification.addAndShow('error', I18n.t('certificate_authentication.error.generic'))
            console.log "Certificate authentication generic error:", xhr.statusText

$ ->
  mconf.CertificateAuthentication.bind()
