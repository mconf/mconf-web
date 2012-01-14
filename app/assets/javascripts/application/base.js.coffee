# TODO: This file has utility functions of all kinds, might be
#       better to separate them in more files.

$(document).ready ->

  # Links to open the webconference
  # Open it in a new borderless window
  $("a.open-webconf-link").live "click", (e) ->
    window.open $(this)[0].href, "_blank", "resizable=yes"
    e.preventDefault()

# Changes the type of an input tag
# Example:
#   changeInputType("#moderator_password", 'password')
window.changeInputType = (id, type) ->
  marker = $("<span />").insertBefore(id)
  $(id).detach().attr("type", type).insertAfter marker
  marker.remove()



# TODO: check if the code below is being used

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
