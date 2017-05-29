# Groups all resources that need to be bound when new elements are
# displayed in the page (e.g. when a modal window is shown, several things
# should be bound to the html elements added by the modal).
#
# Call `mconf.Resources.bind()` to rebind all components.

# A list of temporary methods registered by the current page to be called when
# `mconf.Resources.bind()` is called.
# Will be emptied when the page is reloaded.
temporaryBinds = []

class mconf.Resources

  # Binds all resources we need to bind when content is added to the page (e.g. a modal
  # is opened).
  @bind: ->
    mconf.Base.bind()
    mconf.Tooltip.bind()
    mconf.HelpIcon.bind()
    mconf.InPlaceEdit.bind()
    mconf.Crop.bind()
    mconf.ClipboardCopy.bind()
    mconf.Dropdown.bind()
    mconf.Notification.bind()
    mconf.PageMenuJs.bind()
    mconf.ShowablePassword.bind()
    mconf.Modal.bind()
    mconf.ConfirmationDialog.bind()
    mconf.ResourceFilter.bind()
    mconf.DateTimeInput.bind()
    mconf.QueryString.bind()
    mconf.Tags.bind()
    mconf.Popover.bind()
    mconf.CertificateAuthentication.bind()
    for method in temporaryBinds
      method.call()

  # Adds a method to the list of temporary methods that should be called when
  # rebinding all components.
  @addToBind: (method) ->
    temporaryBinds.push(method)

  # Unbinds all resources. `parent` is the element that holds all elements that
  # should be unbound e.g. the modal window that was closed.
  @unbind: (parent) ->
    parent ?= 'body'
    mconf.Base.unbind?(parent)
    mconf.Tooltip.unbind?(parent)
    mconf.HelpIcon.unbind?(parent)
    mconf.InPlaceEdit.unbind?(parent)
    mconf.Crop.unbind?(parent)
    mconf.ClipboardCopy.unbind?(parent)
    mconf.Dropdown.unbind?(parent)
    mconf.Notification.unbind?(parent)
    mconf.PageMenuJs.unbind?(parent)
    mconf.ShowablePassword.unbind?(parent)
    mconf.Modal.unbind?(parent)
    mconf.ConfirmationDialog.unbind?(parent)
    mconf.ResourceFilter.unbind?(parent)
    mconf.DateTimeInput.unbind?(parent)
    mconf.QueryString.unbind?(parent)
    mconf.Tags.unbind?(parent)
    mconf.Popover.unbind?(parent)
    mconf.CertificateAuthentication.unbind?(parent)
