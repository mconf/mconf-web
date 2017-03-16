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
  $(".status", container).text("?")

successStatus = (data) ->
  target = $(".status", container)
  if data.running is "false"
    target.removeClass("running")
    target.addClass("not-running")
    target.text(I18n.t('custom_bigbluebutton_rooms.invite_header.not_running'))
  else
    target.removeClass("not-running")
    target.addClass("running")
    target.text(I18n.t('custom_bigbluebutton_rooms.invite_header.running'))
