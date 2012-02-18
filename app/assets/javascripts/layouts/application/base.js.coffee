# TODO: This file has utility functions of all kinds, might be
#       better to separate them in more files.

$(document).ready ->

  # Links to open the webconference
  # Open it in a new borderless window
  $("a.webconf-start-link:not(.disabled)").on "click", (e) ->
    window.open $(this)[0].href, "_blank", "resizable=yes"
    e.preventDefault()

  # Disable the click in any link with the 'disabled' class
  $("a.disabled").on "click", (e) ->
    false

  # Add a title and tooltip to elements that can only be used by a logged user
  $(".login-to-enable").each (index) ->
    $(this).attr("title", "You need to be logged in") # TODO: get from i18n
    $(this).addClass("tooltipped")
    $(this).addClass("upwards")

  # Use jquery for placeholders in browsers that don't support it
  $('input[placeholder], textarea[placeholder]').placeholder();

  # auto focus the first element with the attribute 'autofocus' (in case the
  # browser doesn't do it)
  $('[autofocus]').first().focus()

# Changes the type of an input tag
# Example:
#   changeInputType("#moderator_password", 'password')
window.changeInputType = (id, type) ->
  marker = $("<span />").insertBefore(id)
  $(id).detach().attr("type", type).insertAfter marker
  marker.remove()



# TODO: check if the code below is being used / works

jQuery.fn.submitWithAjax = ->
  @submit ->
    $.post @action, $(this).serialize(), null, "script"
    false
  this

jQuery.fn.postsForm = (route) ->
  @ajaxForm
    dataType: "script"
    success: (data) ->
      window.location = route  if data is ""

jQuery.fn.ajaxLink = ->
  @click (data) ->
    $.get @href, {}, ((data) ->
      eval data
    ), "script"
    false
  this
