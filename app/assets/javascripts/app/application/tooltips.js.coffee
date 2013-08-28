# We use tooltips from bootstrap, so all we have to do is associate the proper elements
# calling bootstrap's `tooltip()`.
class mconf.Tooltip
  @bind: ->
    $("a[rel=popover]").popover()
    $(".tooltip").tooltip()
    $(".tooltipped").tooltip()
    $("a[rel=tooltip]").tooltip()

$ ->
  mconf.Tooltip.bind()
