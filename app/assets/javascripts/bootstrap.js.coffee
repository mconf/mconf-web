class mconf.Tooltip

  @bind: ->
    $("a[rel=popover]").popover()
    $(".tooltip").tooltip()
    $(".tooltipped").tooltip()
    $("a[rel=tooltip]").tooltip()

class mconf.Resources
  @bind: ->
    mconf.Tooltip.bind()

$ ->
  mconf.Resources.bind()