class mconf.CertificateAuthentication

  @bind: ->
    $('.certificate-auth-trigger').on 'click', (e) ->
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
              # TODO: show the error as a notification
              console.log "Certificate authentication error:", response.error

          # something went wrong, show a generic error
          else
            console.log "Certificate authentication generic error:", xhr.statusText

$ ->
  mconf.CertificateAuthentication.bind()
