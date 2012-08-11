# This view is shown as a modal window

class window.mconf.EditBbbRoom

  @setup: ->
    # Closes the modal window when the form is submitted
    button = "form.edit_bigbluebutton_room input[type=submit]"
    $(document).on "click", button, -> closeModalWindows()
