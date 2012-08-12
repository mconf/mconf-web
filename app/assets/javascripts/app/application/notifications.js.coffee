# Notifications using jquery.noty

# Default options for noty
defaultOpts =
  closable: true
  timeout: true
  force: false
  modal: false
  timeout: 6000
  speed: 200
  textAlign: 'center'
  layout: 'topCenter'
  closeButton: true

class mconf.Notification

  @bind: ->
    $("div[name='error'], div[name='alert']", "#notification-flashs").each ->
      opts = $.extend {}, defaultOpts,
        text: $(this).text()
        type: 'error'
        force: true
        timeout: false
      noty opts
    $("#notification-flashs > div[name='success']").each ->
      opts = $.extend {}, defaultOpts,
        text: $(this).text()
        type: 'success'
      noty opts
    $("#notification-flashs > div[name='notice']").each ->
      opts = $.extend {}, defaultOpts,
        text: $(this).text()
        type: 'alert'
      noty opts

$ ->
  mconf.Notification.bind()
