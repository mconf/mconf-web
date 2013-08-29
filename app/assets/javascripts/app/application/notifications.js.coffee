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
      showNotification(this, "error")
    $("#notification-flashs > div[name='success']").each ->
      showNotification(this, "success")
    $("#notification-flashs > div[name='notice']").each ->
      showNotification(this, "notice")

showNotification = (target, type) ->
  $target = $(target)

  unless $target.attr("data-notification-shown") is "1"
    $target.attr("data-notification-shown", "1")

    opts = {}
    switch type
      when "success"
        opts = $.extend {}, defaultOpts,
          text: $target.text()
          type: 'success'
      when "error"
        opts = $.extend {}, defaultOpts,
          text: $target.text()
          type: 'error'
          force: true
          timeout: false
      else
        opts = $.extend {}, defaultOpts,
          text: $target.text()
          type: 'alert'

    noty(opts)

$ ->
  mconf.Notification.bind()
