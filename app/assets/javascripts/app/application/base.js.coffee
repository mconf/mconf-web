# TODO: This file has utility functions of all kinds, might be
#       better to separate them in more files.

# Global object to store our classes, methods, etc.
window.mconf = {}

$ ->

  # Setting I18n-js with the user language
  I18n.locale = $('html').attr "lang"

  # Links to open the webconference
  # Open it in a new borderless window
  $("a.webconf-start-link:not(.disabled)").on "click", (e) ->
    window.open $(this)[0].href, "_blank", "resizable=yes"
    e.preventDefault()

  # Disable the click in any link with the 'disabled' class
  $("a.disabled").on "click", (e) ->
    false

  # Add a title and tooltip to elements that can only be used by a logged user
  $(".login-to-enable").each (idx) ->
    $(this).attr("title", "You need to be logged in") # TODO: get from i18n
    $(this).addClass("tooltipped")
    $(this).addClass("upwards")

  # Use jquery for placeholders in browsers that don't support it
  if jQuery().placeholder
    $('input[placeholder], textarea[placeholder]').placeholder()

  # auto focus the first element with the attribute 'autofocus' (in case the
  # browser doesn't do it)
  $('[autofocus]').first().focus()

  # links that automatically collapse or expand blocks inside a parent
  # div. Ex:
  # <div id="event_123">
  #   <div class"block-collapsed">
  #     i'm collapsed
  #     <a href="#event_123" class="link-to-expand">more</a>
  #   </div>
  #   <div class"block-expanded">
  #     i'm expanded
  #     <a href="#event_123" class="link-to-collapse">less</a>
  #   </div>
  # </div>
  $('a.link-to-expand').on "click", (e) ->
    e.preventDefault()
    parent = $("#" + $(this).attr("href"))
    parent.find(".block-collapsed").hide()
    parent.find(".block-expanded").show()
  $('a.link-to-collapse').on "click", (e) ->
    e.preventDefault()
    parent = $("#" + $(this).attr("href"))
    parent.find(".block-collapsed").show()
    parent.find(".block-expanded").hide()

  # Items with this class will only be visible when the item defined
  # by the id in the 'data-hover-tracked' attribute is hovered. Ex:
  # <div class="visible-on-hover" data-hover-tracked="event_123"></div>
  $('.visible-on-hover').each (idx) ->
    target = $(this)
    tracked = $("#" + $(this).attr("data-hover-tracked"))
    tracked.hover (e) ->
      target.show()
    , (e) ->
      target.hide()

  # Links with 'data-open-file' will trigger a click
  # in the input[type=file] element pointed by 'href'
  $("a[data-open-file]").on "click", (e) ->
    e.preventDefault()
    $($(this).attr("href")).click()

  # Links with 'submit-form' will trigger a submit
  # in the form pointed by 'href'.
  $("a.submit-form, button.submit-form").on "click", (e) ->
    e.preventDefault()
    $($(this).attr("href")).submit()


# Returns true if we're currently in the view 'action' inside 'controller'
# If 'action' is empty, will check only for the controller
# Ex:
#   isOnPage 'homes', 'show'
#   isOnPage 'spaces', 'new|create'
#   isOnPage 'events'
window.isOnPage = (controller, action='') ->
  if action is ''
    return $('body').is ".#{controller}"
  else
    actions = action.split("|")
    for act in actions
      if $('body').is ".#{controller}.#{act}"
        return true
    return false
