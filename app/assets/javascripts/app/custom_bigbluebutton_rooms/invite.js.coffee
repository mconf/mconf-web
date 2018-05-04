container = "#webconf-room-invite-header .room-status"

$ ->
  if isOnPage 'custom_bigbluebutton_rooms', 'invite|invite_userid|auth'
    $('#user_name').on "keydown keyup input", =>
      hasGuestName()
    $('.btn-guest').on "click", =>
      guestSelected()
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
    $('.btn-room-status').attr('disabled', true)
  else
    message.text("")
    $('.btn-room-status').attr('disabled', false)

hasGuestName = ->
  nextButton = $('.btn-guest-next')
  guestName = $('#user_name')

  if guestName.val()?.length > 0
    nextButton.attr('disabled', false)
  else
    nextButton.attr('disabled', true)

guestSelected = ->
  $('#guest-login').show()
  $('#choose-login').hide()
