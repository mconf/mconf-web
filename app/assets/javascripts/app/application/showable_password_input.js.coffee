# Inputs with a checkbox that changes the type of the input
# to show passwords as text (and the opposite).
class mconf.ShowablePassword

  # Clicking in the checkboxes changes the type of the input to text/password.
  @bind: ->
    $(".showable_password_show").off "click.mconfShowablePassword"
    $(".showable_password_show").on "click.mconfShowablePassword", ->
      target = $(this).parent().parent().find("input.showable_password")
      id = "#" + target.attr("id")
      if $(this).is(':checked')
        changeInputType(id, "text")
      else
        changeInputType(id, "password")

$ ->
  mconf.ShowablePassword.bind()

# Changes the type of an input tag.
# Example:
#   changeInputType("#moderator_key", 'password')
changeInputType = (id, type) ->
  marker = $("<span />").insertBefore(id)
  $(id).detach().attr("type", type).insertAfter marker
  marker.remove()
