# Notifications using jquery.noty
$(document).ready ->

  # default options for noty
  noty_opt =
    closable: true
    timeout: true
    force: false
    modal: false
    timeout: 6000
    textAlign: 'center'
    layout: 'top'

  $("#notification-flashs > div[name='error']").each ->
    opts = $.extend {}, noty_opt,
      text: $(this).text()
      type: 'error'
      force: true
      timeout: false
    noty opts
  $("#notification-flashs > div[name='success']").each ->
    opts = $.extend {}, noty_opt,
      text: $(this).text()
      type: 'success'
    noty opts
  $("#notification-flashs > div[name='notice']").each ->
    opts = $.extend {}, noty_opt,
      text: $(this).text()
      type: 'alert'
    noty opts
