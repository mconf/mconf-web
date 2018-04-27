container = "#webconf-room-invite-header .room-status"

$ ->
  if isOnPage 'custom_bigbluebutton_rooms', 'invite|invite_userid|auth'
    updateStatus()
    setInterval updateStatus, 10000

    if $("#error-wrapper").length > 0
      body = $("body")
      body.removeClass("running")
      body.removeClass("not-running")
      body.addClass("error")

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
  message = $(".description-status")
  if data.running is "false"
    message.text(I18n.t('custom_bigbluebutton_rooms.invite.webconference_not_running'))
    $('.btn-primary').attr('disabled', true)
  else
    message.text("")
    $('.btn-primary').attr('disabled', false)
