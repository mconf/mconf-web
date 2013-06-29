$ ->
  if isOnPage 'custom_bigbluebutton_rooms', 'invite|auth'
    bindAccessTypeSelection()

bindAccessTypeSelection = ->
  $(".invite-desktop:not(.active)").on "click", (e) ->
    window.location.href = $(this).attr("data-url")

  $(".invite-mobile:not(.active)").on "click", (e) ->
    if !$(e.target).is("a")
      window.location.href = $(this).attr("data-url")
