# Changes the type of an input tag
# Example:
#   changeInputType("#moderator_password", 'password')
window.changeInputType = (id, type) ->
  marker = $("<span />").insertBefore(id)
  $(id).detach().attr("type", type).insertAfter marker
  marker.remove()

# clicking in the checkbox changes the type of the input to text/password
$ ->
  $(document).on "click", ".showable_password input[type=checkbox]", ->
    target = $(this).parent().find("input.showable_password")
    id = "#" + target.attr("id")
    if $(this).is(':checked')
      changeInputType(id, "text")
    else
      changeInputType(id, "password")
