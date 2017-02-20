class mconf.CertificateAuthentication

  redirect_on_success = ->
    if $('.certificate-login-error').length == 0
      window.location = '/home'

      setTimeout redirect_on_success, 2000

  # Binds all certificate authentication login modal events
  @bind: ->

    # Redirect after some time has passed
    $('a#certificate-login').on 'modal-shown', ->
      setTimeout redirect_on_success, 2000

    $('a#certificate-login').on 'modal-hide', ->
      redirect_on_success()

    # Show an error message if server returns 40x or 50x
    $('a#certificate-login').on 'modal-error', ->
      $(this).addClass('certificate-login-error')
      $('.modal.xhr-error').load('/certificate_error')
      .hide()
      .fadeIn('slow');
