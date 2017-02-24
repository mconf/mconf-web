# This class contains all functionally to abstract bootstrap's modal and whatever
# other libraries are used for modal windows.
#
# Use the class 'open-modal' in a `<a>` tag to open its content in a modal.
# If the `href` is a link, it will be loaded (ajax) and the content will be rendered
# in the modal. If the `href` points to an id (e.g. #my-element), the element's content
# will be displayed as a modal window.
# To view more options see `mconf.Modal.showWindow()`.
#
# Modals have a default width set by bootstrap. To set a different width, set `data-modal-width`
# in your element. The values accepted are:
# * `small`: Adds a css class to force the modal to be narrower
# * `large`: Adds a css class to force the modal to be wider
#
# Triggers the events:
# * `modal-before-configure`: First event triggered when the modal starts being configured.
# * `modal-open`: From bootstrap, triggered immediately after `show` is called.
# * `modal-opened`: From bootstrap, triggered after the modal is loaded and shown.
# * `modal-hide`: From bootstrap, triggered immediately after `hide` is called.
# * `modal-hidden`: From bootstrap, triggered after the modal is closed.
#
class mconf.Modal

  # Shows the modal window using the options in 'options'
  # Options accepted:
  # * `element`: The element that generated the event (i.e. the link or button that was clicked).
  # * `target`: The target modal that will be opened. Can be a selector to an element already in
  #   the page (e.g. '#my-modal') or a link to a URL that will be loaded to get the modal content.
  # * `data`: Can be used to pass the content that should be shown in the modal via javascript. To
  #   use it, leave `target` as `null` and set `data` with the string containing the HTML to be
  #   shown.
  # * `modalWidth`: To force the modal to assume a different width. Accepted values: "small".
  @showWindow: (options) ->
    localOptions =
      show: true
      replace: true
      keyboard: true  # Closes the modal when escape key is pressed
      # maxHeight: 0.7 * $(window).height()
      # modalOverflow: true

    # if target is a url, the content will be loaded from it
    href = options.target
    if href? and href[0] is "#" and $(href)?
      isRemote = false
      $modal = $(options.target)

    # not an url, assumes it is the selector to the element that has the content
    # for the modal or there is content set in options.data
    else
      $modal = $("<div/>")
      $modal.addClass('modal')
      $modalDialog = $("<div/>")
      $modalDialog.addClass("modal-dialog")
      $modalContent = $("<div/>")
      $modalContent.addClass("modal-content")
      $modalDialog.append($modalContent)
      $modal.append($modalDialog)
      if options.data?
        isRemote = false
        $modalContent.append(options.data)
      else
        isRemote = true

    # need to add this so the keyboard shortcuts (ESC mainly) will work as the modal is opened
    # see more about it at https://github.com/twbs/bootstrap/issues/4663
    $modal.attr("tabindex", -1)

    # if the user wants a different width for the modal, add the proper css class
    modalWidth = $(options.element).attr("data-modal-width") || options.modalWidth
    switch modalWidth
      when "small"
        $modal.children(".modal-dialog").addClass("modal-sm")
      when "large"
        $modal.children(".modal-dialog").addClass("modal-lg")

    # set up the events
    $modal.on "show", ->
      $(options.element).trigger("modal-show")
    $modal.on "shown", ->
      $modal.modal("layout")
      mconf.Resources.bind() # bind resources to the new modal
      $("[autofocus]", $modal).focus()
      $(options.element).trigger("modal-shown")
    $modal.on "hide", ->
      $(options.element).trigger("modal-hide")
    $modal.on "hidden", ->
      $(options.element).trigger("modal-hidden")

    jQuery.extend localOptions, options

    # if its a link, load the content and then show it
    if isRemote
      $modal.find(".modal-content").load options.target, "", (responseText, textStatus, xhr) ->
        $modal.modal(localOptions)

        # Remote returns an http error code show
        if !(xhr.status >= 200 && xhr.status < 400)
          $modal.addClass('xhr-error')
          $modal.html("<div class='status'> <i class='fa fa-frown-o'></i> #{xhr.statusText} </div>")

          $(options.element).trigger("modal-error")

    # not a link, simply show the content
    else
      $modal.modal(localOptions)

  # Close all modal modal windows
  @closeWindows: ->
    $(".modal").modal("hide")

  @unbind: ->
    $("a.open-modal:not(.disabled)").off "click.mconfModal"
    $("a.webconf-join-mobile-link:not(.disabled)").off "click.mconfModal"

  @bind: ->
    @unbind()

    # General links to open with a modal window
    $("a.open-modal:not(.disabled)").on "click.mconfModal", bindAndOpen

    # Links to open the window to join a webconference from a mobile device
    $("a.webconf-join-mobile-link:not(.disabled)").on "click.mconfModal", bindAndOpen

    # For elements with the class .close-dialog we add attributes so that bootstrap will make
    # them close the modal automatically
    $(".modal .close-dialog").attr("data-dismiss", "modal")

$ ->
  mconf.Modal.bind()

# Method called when an <a> is clicked to be opened in a modal window.
# Used internally (in this file) only.
bindAndOpen = (event) ->
  event.preventDefault()
  options = {}

  # element that generated the event
  # if it's a span inside an anchor, we want the anchor, so `currentTarget` is better than `target`
  options.element = event.currentTarget

  options.target = $(this).attr("href")

  $(options.element).trigger("modal-before-configure")

  mconf.Modal.showWindow options
