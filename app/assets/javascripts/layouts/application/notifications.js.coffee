# hide the notification bar on click
#$("#notification-flashs").livequery "click", ->
#  $("#notification-flashs").animate
#    top: -$(this).outerHeight() - 5
#  , 500

$(document).ready ->
  $("#notification-flashs > div[name='success']").each ->
    ui.notify($(this).text()).closable().hide(8000).effect('slide')
    $(this).addClass "success"
  $("#notification-flashs > div[name='notice']").each ->
    ui.warn($(this).text()).closable().hide(8000).effect('slide')
  $("#notification-flashs > div[name='error']").each ->
    ui.error($(this).text()).closable().sticky().effect('slide')

# hide closable notifications onclick
$("#notifications .closable").livequery "click", ->
  $(this).hide()
