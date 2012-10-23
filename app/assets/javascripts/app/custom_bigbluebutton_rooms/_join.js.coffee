$(document).ready ->
  if isOnPage 'custom_bigbluebutton_rooms', 'join|auth'
    ajax_request()
    setInterval ajax_request(), 3000
  

ajax_request = ->
  url = $("#webconf-room-status").attr("data-url")
  $.ajax
    url: url
    dataType: "json"
    success: onSuccess
    contentType: "application/json"

onSuccess = (data) ->
  if data.running is "true"
    window.location.reload()
  setTimeout(ajax_request(), 3000)
