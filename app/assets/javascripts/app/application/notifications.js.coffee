# Notifications using toastr

defaultOpts =
  tapToDismiss: false
  positionClass: 'toast-top-full-width'
  iconClass: ''
  hideMethod: 'slideUp'
  hideDuration: 200
  showMethod: 'slideDown'
  showDuration: 400
  closeButton: true

class mconf.Notification

  @bind: ->
    $("div[name='error'], div[name='alert']", "#notification-flashs").each ->
      showNotification(this, "error")
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
        method = toastr.success
        opts = $.extend {}, defaultOpts,
      when "error"
        method = toastr.error
        opts = $.extend {}, defaultOpts,
          force: true
          timeOut: 0
          extendedTimeOut: 0
      else
        method = toastr.warning

    toastr.options = opts
    method $target.text()

$ ->
  mconf.Notification.bind()
