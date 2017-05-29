# Wrap for bootstrap's popovers.
class mconf.Popover

  @bind: ->
    $('[data-toggle="popover"]').popover()

$ ->
  mconf.Popover.bind()
