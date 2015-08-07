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

    # Add a title and tooltip to spaces that can only be used by a logged user
    $(".register-to-view-space").each ->
      $(this).attr("title", I18n.t("_other.register_to_view_space"))
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
    $('.visible-on-hover').each ->
      $target = $(this)
      $tracked = $("#" + $(this).attr("data-hover-tracked"))
      $tracked.on "mouseenter.mconfBase", (e) -> $target.show()
      $tracked.on "mouseleave.mconfBase", (e) -> $target.hide()

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
  @stringToSlug: (str) ->
    return '' if !str?

    str = str.toLowerCase()
    str = removeDiacritics(str)
    str = str.replace(/[^A-Za-z0-9\-_ ]*/g, '')
       .replace(/\s+/g, '-')         # collapse whitespace and replace by '-'
       .replace(/-+/g, '-')          # collapse dashes
       .replace(/-$/g, '')           # dash as the last char
       .replace(/^-/g, '')           # dash as the first char

  # Returns whether an email is valid or not.
  # From: http://www.w3resource.com/javascript/form/email-validation.php
  @validateEmail: (value) ->
    /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(value)

  # Escapes HTML characters from a string
  escape = document.createElement('textarea')
  @escapeHTML: (string) ->
    escape.innerHTML = string
    escape.innerHTML

  # taken from http://shiplu.mokadd.im/61/parse-query-string-by-pure-javascrirpt/
  @getUrlParts = (url) ->
    # url contains your data.
    qs = url.indexOf('?')
    if qs == -1
      return []
    fr = url.indexOf('#')
    q = ''
    q = if fr == -1 then url.substr(qs + 1) else url.substr(qs + 1, fr - qs - 1)
    parts = q.split('&')
    vars = {}
    i = 0
    while i < parts.length
      p = parts[i].split('=')
      if p[1]
        vars[decodeURIComponent(p[0])] = decodeURIComponent(p[1])
      else
        vars[decodeURIComponent(p[0])] = ''
      i++
    # vars contain all the variables in an array.
    vars

  @urlFromParts = (parts) ->
    if parts? and Object.keys(parts).length > 0
      url = '?'
      arr = []
      for name, value of parts
        arr.push "#{name}=#{value}"

      url + arr.join('&')
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
