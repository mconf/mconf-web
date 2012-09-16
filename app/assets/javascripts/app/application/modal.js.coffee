# Use the class 'open-modal' in a <a> to open as modal.
# If 'href' is a link, it will be executed (ajax) and the content
# will be renderd in the modal. If the 'href' points to an id
# (e.g. #my-element), the element's content will be displayed inside
# the modal window.

class mconf.Modal

  # Shows the modal window using the options in 'options'
  @showWindow: (options) ->
    localOptions = {}
    #   backdrop: true
    #   keyboard: true
    # jQuery.extend localOptions, options
    if options.target?
      el = $(options.target)
      delete options.target
    else
      el = $("<div/>")
    jQuery.extend localOptions, options
    el.dialog2(localOptions)

  # Global method to close all modal windows open
  @closeWindows: ->
    # TODO: test
    $(".modal").dialog2("close")

  # Links a <a> to be opened with a modal window.
  # Used internally only.
  @bind: (event) ->
    event.preventDefault()
    options = {}

    # check whether we should show content that's already in the page
    # TODO: not yet being used in the app, test better when first used
    href = $(this).attr("href")
    if href? and href[0] is "#" and $(href)?
      options.target = href

    # otherwise we render the content pointed by this <a>
    else
      options.content = href

    mconf.Modal.showWindow options

$ ->
  # General links to open with a modal window
  openModal = "a.open-modal:not(.disabled)"
  $(document).on "click", openModal, mconf.Modal.bind

  # Links to open the window to join a webconference from a mobile device
  joinMobile = "a.webconf-join-mobile-link:not(.disabled)"
  $(document).on "click", joinMobile, mconf.Modal.bind

  # Links to report a spam are also in a modal
  spam = "a.spam-report:not(.disabled)"
  $(document).on "click", spam, mconf.Modal.bind
