container = "#webconf-room-status"

$ ->
  if isOnPage 'custom_bigbluebutton_rooms', 'invite|auth'
    updateStatus()
    setInterval updateStatus, 10000

updateStatus = ->
  url = $(container).attr("data-url")
  $.ajax
    url: url
    dataType: "json"
    error: errorStatus
    success: successStatus
    contentType: "application/json"

errorStatus = (data) ->
  $(".status", container).text("?")

successStatus = (data) ->
  target = $(".status", container)
  if data.running is "false"
    target.removeClass("label-success")
    target.addClass("label-important")
    target.text(I18n.t('custom_bigbluebutton_rooms.invite.not_running'))
  else
    target.removeClass("label-important")
    target.addClass("label-success")
    target.text(I18n.t('custom_bigbluebutton_rooms.invite.running'))
