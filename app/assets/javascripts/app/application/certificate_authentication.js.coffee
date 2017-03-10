class mconf.CertificateAuthentication

  @bind: ->
    $('.certificate-auth-trigger').off 'click.mconfCertificateAuthentication'
    $('.certificate-auth-trigger').on 'click.mconfCertificateAuthentication', (e) ->
      e.preventDefault()

      $.ajax $(this).attr('href'),
        contentType: 'application/json'
        complete: (xhr) ->
          response = xhr.responseJSON

          # the expected response, a json with info about success or error
          if xhr.status == 200
            if response.result == true
              window.location = response.redirect_to
            else
              console.log "Certificate authentication error:", response
              mconf.Notification.addAndShow('error', response.error)

          # something went wrong, show a generic error
          else
            error = response.error ? I18n.t('certificate_authentication.error.generic')
            mconf.Notification.addAndShow('error', error)
            console.log "Certificate authentication error:", xhr.statusText

$ ->
  mconf.CertificateAuthentication.bind()
