container = "#webconf-room-invite-header .room-status"

$ ->
  if isOnPage 'custom_bigbluebutton_rooms', 'invite|invite_userid|auth'
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
  target = $(".status", container)
  target.text("?")
  target.attr("title", null)
  mconf.Tooltip.bindOne(target)

successStatus = (data) ->
  target = $(".status", container)
  message = $(".status-text")
  body = $("body")
  if data.running is "false"
    target.removeClass("running")
    target.addClass("not-running")
    target.text(I18n.t('custom_bigbluebutton_rooms.invite_header.not_running'))
    target.attr('title', I18n.t('custom_bigbluebutton_rooms.invite_header.not_running_tooltip'))
    message.text(I18n.t('custom_bigbluebutton_rooms.invite_header.webconference_not_running'))
    body.removeClass("running")
    body.addClass("not-running")
  else
    target.removeClass("not-running")
    target.addClass("running")
    target.text(I18n.t('custom_bigbluebutton_rooms.invite_header.running'))
    target.attr('title', I18n.t('custom_bigbluebutton_rooms.invite_header.running_tooltip'))
    message.text(I18n.t('custom_bigbluebutton_rooms.invite_header.webconference_running'))
    body.removeClass("not-running")
    body.addClass("running")
  mconf.Tooltip.bindOne(target)
