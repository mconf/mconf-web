$(document).ready ->
  if isOnPage 'custom_bigbluebutton_rooms', 'join_mobile'
    # automatically redirect the user to the mobile application on page load
    redirectToMobileSession()

redirectToMobileSession = ->
  url = $("#mobile-url").attr("href")
  console.log 'redir to', url
  window.location = url
