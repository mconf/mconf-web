class mconf.Tooltip
  @bind: ->
    $("a[rel=popover]").popover()
    $(".tooltip").tooltip()
    $(".tooltipped").tooltip()
    $("a[rel=tooltip]").tooltip()

# Groups all resources that need to be bound when new elements are
# displayed in the page (e.g. when a modal window is shown, the tooltips
# should be bound to the html elements in the modal).
class mconf.Resources
  # TODO: there's a risk of rebinding events that will end up being called several times,
  #       review all classes that bind events to use namespaces
  @bind: ->
    mconf.InPlaceEdit.bind()
    mconf.Tooltip.bind()

$ ->
  mconf.Resources.bind()
