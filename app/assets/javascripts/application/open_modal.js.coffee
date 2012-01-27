applyModalWindow = ->
  #$(this).colorbox
    #scrolling: false,
    #initialWidth: 32,
    #initialHeight: 32,
    #transition: 'fade',
    #speed: 100,
    #fastIframe: false

  $(this).fancybox
    autoScale: true,
    autoDimensions: true,
    centerOnScroll: true,
    hideOnContentClick: false


# Associates types below with a fancybox
$(document).ready ->

  # General links to open with a modal window
  $('a.open-modal:not(.disabled)').each applyModalWindow

  # Links to open the window to join a webconference from a mobile device
  $("a.webconf-join-mobile-link:not(.disabled)").each applyModalWindow

  $(document).bind 'cbox_complete', ->
    w = $('#cboxLoadedContent').width()
    h = $('#cboxLoadedContent').height()
    #$('#cboxLoadedContent').width(w - 30)
    #$('#cboxLoadedContent').height(h - 30)

