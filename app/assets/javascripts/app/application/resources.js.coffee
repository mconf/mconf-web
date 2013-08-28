# Groups all resources that need to be bound when new elements are
# displayed in the page (e.g. when a modal window is shown, several things
# should be bound to the html elements added by the modal).
#
# Call `mconf.Resources.bind()` to rebind all components.
#
class mconf.Resources
  @bind: ->
    mconf.Tooltip.bind()
    mconf.InPlaceEdit.bind()
    mconf.Crop.bind()
    mconf.Dropdown.bind()
    mconf.Notification.bind()
    mconf.SelectableButtons.bind()
    mconf.ShowablePassword.bind()
