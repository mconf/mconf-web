$(document).ready ->
  if isOnPage 'custom_bigbluebutton_rooms', 'join|auth'
    ajaxRequest()
    setInterval ajaxRequest(), 3000

ajaxRequest = ->
  url = $("#webconf-room-status").attr("data-url")
  $.ajax
    url: url
    dataType: "json"
    success: onSuccess
    contentType: "application/json"

onSuccess = (data) ->
  if data.running is "true"
    window.location.reload()
  setTimeout(ajaxRequest(), 3000)
