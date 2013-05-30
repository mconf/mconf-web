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
  @bind: ->
    mconf.Tooltip.bind()

$ ->
  mconf.Resources.bind()
