confirmationTemplate = HandlebarsTemplates['application/confirmation_dialog']

# Replace Rails' confirmation dialog with a translatable Bootstrap modal dialog.
# Based on: https://gist.github.com/1943094
class mconf.ConfirmationDialog

  # shows a dialog with the `message`, being triggered by the `element`.
  @show: (message, element) ->
    params =
      title: I18n.t('_js.confirmation_dialog.title')
      cancel: I18n.t('_js.confirmation_dialog.cancel')
      confirm: I18n.t('_js.confirmation_dialog.confirm')
      message: message
    modalContent = confirmationTemplate(params)

    # uses our own modal classes so it's just like any other modal window in the application
    mconf.Modal.showWindow
      element: element
      data: modalContent
      modalWidth: "small"
      backdrop: "static" # real modal, user can't do anything until the modal is closed

$ ->
  $.rails.confirm = (message) ->
    mconf.ConfirmationDialog.show(message, this)
    false
