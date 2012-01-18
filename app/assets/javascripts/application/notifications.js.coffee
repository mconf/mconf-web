# hide the notification bar on click
$("#notification-flashs").livequery "click", ->
  $("#notification-flashs").animate
    top: -$(this).outerHeight() - 5
  , 500
