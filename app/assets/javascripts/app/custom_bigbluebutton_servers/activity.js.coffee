$ ->
  if isOnPage('custom_bigbluebutton_servers', 'activity')
    setUpdateInterval()

setUpdateInterval = ->
  setInterval(update, 30000)

update = ->
  url = $("#server-activity-content").attr("data-update-url")
  $("#server-activity-content").load(url, updateFinished)

updateFinished = (text, status) ->
  $("#server-activity-content").parent().addClass("updated")
  setTimeout( ->
    $("#server-activity-content").parent().removeClass("updated")
  , 3000)
