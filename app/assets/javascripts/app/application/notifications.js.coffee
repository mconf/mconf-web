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
    $("div[name='error']", "#notification-flashs").each ->
      showNotification(this, "error")
    $("div[name='alert'], div[name='warn']", "#notification-flashs").each ->
      showNotification(this, "warn")
    # notice messages are usually success messages in form updates, so consider them
    # always as success
    $("div[name='success'], div[name='notice']", "#notification-flashs").each ->
      showNotification(this, "success")

  # Adds a new notification of type `type` to the page.
  # `type` can be "success", "error", or "notice".
  # `text` is the message included inside the notification.
  # The notification is only added to the page but will *not* be displayed. To do so,
  # call `mconf.Notification.bind()`.
  @add: (type, text) ->
    notification = $("<div></div>")
    notification.attr("name", type)
    notification.html(text)
    $('#notification-flashs').append(notification)

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
      when "warn"
        opts = $.extend {}, defaultOpts,
          text: $target.text()
          type: 'alert'
      else
        opts = $.extend {}, defaultOpts,
          text: $target.text()
          type: 'alert'

    opts.text = mconf.Base.escapeHTML(opts.text)
    noty(opts)

$ ->
  mconf.Notification.bind()
