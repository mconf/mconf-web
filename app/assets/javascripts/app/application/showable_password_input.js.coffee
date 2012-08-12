# Inputs with a checkbox that changes the type of the input
# to show passwords as text (and the opposite).
class mconf.ShowablePassword

  # Changes the type of an input tag.
  # Example:
  #   changeInputType("#moderator_password", 'password')
  @changeInputType: (id, type) ->
    marker = $("<span />").insertBefore(id)
    $(id).detach().attr("type", type).insertAfter marker
    marker.remove()

  # Clicking in the checkboxes changes the type of the input to text/password.
  @bind: ->
    $(document).on "click", ".showable_password input[type=checkbox]", ->
      target = $(this).parent().find("input.showable_password")
      id = "#" + target.attr("id")
      if $(this).is(':checked')
        mconf.ShowablePassword.changeInputType(id, "text")
      else
        mconf.ShowablePassword.changeInputType(id, "password")

$ ->
  mconf.ShowablePassword.bind()