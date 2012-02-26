# Opens a link in a modal window (popup, lightbox)
applyModalWindow = (event) ->
  event.preventDefault();

  # calls a function defined in the attribute data-modal-options
  # to get the custom options for this modal
  fn = window[$(this).attr('data-modal-options')]
  options = if fn? then fn() else {}

  # Merge default settings with the custom options
  settings =
    href: $(this).attr('href')
    scrolling: false,
    initialWidth: 32,
    initialHeight: 32
  jQuery.extend(settings, options);
  $.colorbox settings

# Global method to close all modal windows open
window.closeModalWindows = ->
  $.colorbox.close()

# Associates types below with a modal popup
$ ->

  # Change some default options for colorbox
  $.colorbox.settings.opacity = 0.6;
  $.colorbox.settings.speed = 100;

  # General links to open with a modal window
  $(document).on "click", "a.open-modal:not(.disabled)", applyModalWindow

  # Links to open the window to join a webconference from a mobile device
  $(document).on "click", "a.webconf-join-mobile-link:not(.disabled)", applyModalWindow
