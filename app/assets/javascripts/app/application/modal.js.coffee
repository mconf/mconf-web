# Use the class 'open-modal' in a <a> to open as modal
# The attr 'data-modal-options' can be used to point to a function
# that should return custom options for the modal window
# The attr 'data-modal-content' can be used to open content that's
# already in the page

class mconf.Modal

  # Shows the modal window using the options in 'options'
  @showWindow: (options) ->
    settings =
      scrolling: false,
      initialWidth: 48,
      initialHeight: 48
      onComplete: ->
        # just in case the contents changed their size
        $.colorbox.resize()
    jQuery.extend settings, options
    $.colorbox settings

  # Global method to close all modal windows open
  @closeWindows: ->
    $.colorbox.close()

  # Links a <a> to be opened with a modal window.
  # Used internally only.
  @bind: (event) ->
    event.preventDefault()

    # calls a function defined in the attribute data-modal-options
    # to get the custom options for this modal
    fn = window[$(this).attr('data-modal-options')]
    options = if fn? then fn() else {}

    # check whether we should show content that's already in the page
    html = null
    elem_name = $(this).attr('data-modal-content')
    if elem_name?
      elem = $("#" + elem_name)
      if elem?
        html = elem.html()

    # if 'html' we show its content, otherwise we render the content
    # pointed by this <a>
    if html?
      settings = { html: html }
    else
      settings = { href: $(this).attr('href') }
    jQuery.extend settings, options

    mconf.Modal.showWindow settings

$ ->

  # Change some default options for colorbox
  $.colorbox.settings.opacity = 0.6
  $.colorbox.settings.speed = 100

  # General links to open with a modal window
  openModal = "a.open-modal:not(.disabled)"
  $(document).on "click", openModal, mconf.Modal.bind

  # Links to open the window to join a webconference from a mobile device
  joinMobile = "a.webconf-join-mobile-link:not(.disabled)"
  $(document).on "click", joinMobile, mconf.Modal.bind
