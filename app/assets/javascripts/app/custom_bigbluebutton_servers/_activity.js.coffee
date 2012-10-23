refresh = ->
  window.location.reload(true)

$(document).ready ->
  if isOnPage 'custom_bigbluebutton_servers', 'activity'
    setInterval refresh, 30000

