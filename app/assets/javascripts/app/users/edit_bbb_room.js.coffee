# This view is shown as a modal window
$ ->
  # closes the modal window when the form is submitted
  $(document).on "click", "form.edit_bigbluebutton_room input[type=submit]", ->
    closeModalWindows()
