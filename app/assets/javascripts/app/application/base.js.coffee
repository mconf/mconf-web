# TODO: This file has utility functions of all kinds, might be
#       better to separate them in more files.

# Global object to store our classes, methods, etc.
window.mconf = {}

# Contains several small javascript components or blocks of code that don't need
# their own class/file.
class mconf.Base

  @bind: ->
    @unbind()

    # Links to open the webconference
    # Open it in a new borderless window
    $("a.webconf-join-link:not(.disabled)").on "click.mconfBase", (e) ->
      window.open $(this)[0].href, "_blank", "resizable=yes"
      e.preventDefault()
      true # so it continues to the next callbacks, if any

    # Opens the link in a new window
    $("a.open-new-window:not(.disabled)").on "click.mconfBase", (e) ->
      window.open $(this)[0].href, "_blank"
      e.preventDefault()
      true # so it continues to the next callbacks, if any

    # Disable the click in any link with the 'disabled' class
    $(".disabled").on "click.mconfBase", (e) ->
      e.preventDefault()
      true # so it continues to the next callbacks, if any

    # Add a title and tooltip to elements that can only be used by a logged user
    $(".login-to-enable").each ->
      $(this).attr("title", I18n.t("_other.login_to_enable"))
      $(this).addClass("tooltipped")
      $(this).addClass("upwards")

    # Add a title and tooltip to elements that can only be used by a logged user
    $(".webconf-not-allowed-create").each ->
      $(this).attr("title", I18n.t("_other.webconference.not_allowed_to_create"))
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
    $('a.link-to-expand').on "click.mconfBase", (e) ->
      e.preventDefault()
      parent = $("#" + $(this).attr("href"))
      parent.find(".block-collapsed").hide()
      parent.find(".block-expanded").show()
    $('a.link-to-collapse').on "click.mconfBase", (e) ->
      e.preventDefault()
      parent = $("#" + $(this).attr("href"))
      parent.find(".block-collapsed").show()
      parent.find(".block-expanded").hide()

    # Items with this class will only be visible when the item defined
    # by the id in the 'data-hover-tracked' attribute is hovered. Ex:
    # <div class="visible-on-hover" data-hover-tracked="event_123"></div>
    # It will wait a little while before showing the element to make it less intrusive
    # and annoying. So it only appears when the user hovers the parent element for
    # time enough.
    $('.visible-on-hover').each ->
      showAnimationDelay = 150
      hideAnimationDelay = 150
      showDelay          = 350

      $target = $(this)
      $tracked = $("#" + $(this).attr("data-hover-tracked"))
      $tracked.on "mouseenter.mconfBase", (e) ->
        $target.data("visible-on-hover-show", true)
        setTimeout( ->
          $target.show(showAnimationDelay) if $target.data("visible-on-hover-show")
        , showDelay)
      $tracked.on "mouseleave.mconfBase", (e) ->
        $target.data("visible-on-hover-show", false)
        $target.hide(hideAnimationDelay)

    # Links with 'data-open-file' will trigger a click
    # in the input[type=file] element pointed by 'href'
    $("a[data-open-file]").on "click.mconfBase", (e) ->
      e.preventDefault()
      $($(this).attr("href")).click()

    # Links with 'submit-form' will trigger a submit
    # in the form pointed by 'href'.
    $("a.submit-form, button.submit-form").on "click.mconfBase", (e) ->
      e.preventDefault()
      $($(this).attr("href")).submit()

  @unbind: ->
    $("a.webconf-join-link:not(.disabled)").off "click.mconfBase"
    $("a.open-new-window:not(.disabled)").off "click.mconfBase"
    $(".disabled").off "click.mconfBase"
    $('a.link-to-expand').off "click.mconfBase"
    $('a.link-to-collapse').off "click.mconfBase"
    $('.visible-on-hover').each ->
      $tracked = $("#" + $(this).attr("data-hover-tracked"))
      $tracked.off "mouseenter.mconfBase"
      $tracked.off "mouseleave.mconfBase"
    $("a[data-open-file]").off "click.mconfBase"
    $("a.submit-form, button.submit-form").off "click.mconfBase"

  # Converts a string into a slug. Should do it as closely as possible from the
  # way slugs are generated in the application using FriendlyId.
  # From: http://dense13.com/blog/2009/05/03/converting-string-to-slug-javascript/
  # direct_input is a boolean to allow more freedom if the slug is applied to the
  # same field the user is currently editing
  @stringToSlug: (str, direct_input=false) ->
    return '' if !str?

    str = str.toLowerCase()
    str = removeDiacritics(str)
    str = str.replace(/[^A-Za-z0-9\-_ ]*/g, '')
       .replace(/\s+/g, '-')         # collapse whitespace and replace by '-'
       .replace(/-+/g, '-')          # collapse dashes
       .replace(/^-/g, '')           # dash as the first char

    if direct_input is false
      str = str.replace(/-$/g, '')   # dash as the last char

    str

  # Returns whether an email is valid or not.
  # From: http://www.w3resource.com/javascript/form/email-validation.php
  @validateEmail: (value) ->
    /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(value)

  # Escapes HTML characters from a string
  escape = document.createElement('textarea')
  @escapeHTML: (string) ->
    escape.innerHTML = string
    escape.innerHTML

  # Parses a query string in the format '?param=1&other=two%20two' into an object
  # in the format { param: '1', other: 'two two' }
  @parseQueryString = (search) ->
    objURL = {}

    replacer = ($0, $1, $2, $3) ->
      objURL[$1] = decodeURIComponent($3.replace(/\+/g, ' '))
      # replace '+' by ' ' because that's what the browser does and
      # decodeURIComponent doesn't

    search.replace(new RegExp( "([^?=&]+)(=([^&]*))?", "g" ), replacer)
    return objURL

  # Transforms a hash in the format { param: '1', other: 'two two' } into
  # a string in the format '?param=1&other=two%20two'.
  @makeQueryString = (params) ->
    if params and not _.isEmpty?(params)
      '?' + _.map(params, (v, k) -> k+'='+encodeURIComponent(v)).join('&')
    else
      ''

$ ->
  # Setting I18n-js with the user language
  I18n.locale = $('html').attr "lang"
  moment.lang(I18n.locale)

  mconf.Base.bind()

# Returns true if we're currently in the view 'action' inside 'controller'
# If 'action' is empty, will check only for the controller
# Ex:
#   isOnPage 'my', 'home'
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
