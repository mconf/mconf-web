# Inputs with a checkbox that changes the type of the input
# to show passwords as text (and the opposite).
class mconf.ShowablePassword

  # Clicking in the checkboxes changes the type of the input to text/password.
  @bind: ->
    $(".showable_password_show").off "click.mconfShowablePassword"
    $(".showable_password_show").on "click.mconfShowablePassword", ->
      target = $(this).parent().parent().find("input.showable_password")
      id = "#" + target.attr("id")
      changeInputType(id, "text")
      $(this).hide()
      $(this).siblings(".showable_password_hide").show()

    $(".showable_password_hide").off "click.mconfShowablePassword"
    $(".showable_password_hide").on "click.mconfShowablePassword", ->
      target = $(this).parent().parent().find("input.showable_password")
      id = "#" + target.attr("id")
      changeInputType(id, "password")
      $(this).hide()
      $(this).siblings(".showable_password_show").show()

$ ->
  mconf.ShowablePassword.bind()

# Changes the type of an input tag.
# Example:
#   changeInputType("#moderator_key", 'password')
changeInputType = (id, type) ->
  marker = $("<span />").insertBefore(id)
  $(id).detach().attr("type", type).insertAfter marker
  marker.remove()
