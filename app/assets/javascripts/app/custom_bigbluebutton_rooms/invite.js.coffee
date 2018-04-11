$ ->
  if isOnPage 'custom_bigbluebutton_rooms', 'invite|invite_userid|auth'
    if $("#error-wrapper").length > 0
      body = $("body")
      body.removeClass("running")
      body.removeClass("not-running")
      body.addClass("error")
