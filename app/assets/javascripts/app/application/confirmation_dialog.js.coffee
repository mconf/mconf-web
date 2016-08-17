confirmationTemplate = HandlebarsTemplates['application/confirmation_dialog']
dialogId = '#confirmation-dialog'

# Replace Rails' confirmation dialog with a translatable Bootstrap modal dialog.
# Based on: https://gist.github.com/1943094
class mconf.ConfirmationDialog

  # Binds the events for all links with confirmation set.
  @bind: ->
    $('[data-confirm]:not(.disabled)').each ->
      $link = $(this)

      $link.off "click.mconfConfirmationDialog"
      $link.on "click.mconfConfirmationDialog", (e) ->
        return if $link.hasClass('disabled') # #1279

        e.preventDefault()

        # first creates the dialog, will only create if it's not there yet
        mconf.ConfirmationDialog.create()

        # clones the button that was clicked to use it as the confirmation button in
        # the confirmation dialog
        $confirmButton = $("#{dialogId} .confirmation-dialog-confirm")
        $newConfirm = $link.clone()
        $newConfirm.removeAttr('data-confirm id')
        $newConfirm.attr('class', $confirmButton.attr('class'))
        $newConfirm.html($confirmButton.html())
        $confirmButton.replaceWith($newConfirm)
        mconf.ConfirmationDialog.show($link)

  # Creates the dialog in the html. Will only do it if the dialog isn't there yet.
  @create: ->
    if $(dialogId).length <= 0
      params =
        title: I18n.t('_js.confirmation_dialog.title')
        cancel: I18n.t('_js.confirmation_dialog.cancel')
        confirm: I18n.t('_js.confirmation_dialog.confirm')
        message: ''
      $('body').append(confirmationTemplate(params))

  # Shows the confirmation dialog.
  # Uses our own modal classes so it's just like any other modal window in the application
  @show: (element) ->
    mconf.Modal.showWindow
      element: element
      target: dialogId
      modalWidth: "small"
      backdrop: "static" # real modal, user can't do anything until the modal is closed

$ ->
  mconf.ConfirmationDialog.bind()

  # catches rails confirmations to set the message in the confirmation dialog
  $.rails.confirm = (message, test) ->
    $("#{dialogId} .modal-body").html(message)
    false
