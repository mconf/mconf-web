$ ->
  if isOnPage 'posts', 'index'

    # focusing any of the elements should make sure the controls are shown
    $('input[type=text], textarea, input[type=submit]', '#new-post').on 'focus click', ->
      showControls()

    # button to close/hide the inputs
    $('.link-cancel', '#new-post').on 'click', ->
      hideControls()

    # ESC anywhere inside this div means 'close it'
    $('#new-post').on 'keyup', (e) ->
      if e.keyCode is 27 # ESC key
        hideControls()

showControls = ->
  $('#new-post').addClass('active')

hideControls = ->
  $('#new-post').removeClass('active')
