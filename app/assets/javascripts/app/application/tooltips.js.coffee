class mconf.Tooltip

  @create: (obj, options={}) ->
    obj.qtip options

  # Inserts a tooltip for every element with the class 'tooltipped' or
  # 'tooltipped-label'. Can be called after ajax updates if new elements
  # with tooltips are added to the page.
  # Uses qTip.
  # Examples:
  #   tooltipped downwards leftwards
  #   tooltipped upwards from-mouse
  @bind: ->
    $(".tooltipped").each ->
      obj = $(this)
      if obj.hasClass("downwards")
        my = "top"
        at = "bottom"
      else if obj.hasClass("upwards")
        my = "bottom"
        at = "top"
      else
        at = "center"
        my = "center"
      if obj.hasClass("leftwards")
        my += " right"
        at += " left"
      else if obj.hasClass("rightwards")
        my += " left"
        at += " right"
      else
        at += " center"
        my += " center"
      target = if obj.hasClass("from-mouse") then "mouse" else obj
      options =
        position:
          my: my
          at: at
          target: target
          adjust:
            method: "shift"
        style:
          classes: "ui-tooltip-tipsy ui-tooltip-mconf"
       mconf.Tooltip.create obj, options

    # A tooltip in the format of a label, inside the component (used mainly
    # for images)
    $(".tooltipped-label").each ->
      obj = $(this)
      if obj.hasClass("downwards")
        at = "bottom center"
      else
        at = "top center"
      options =
        position:
          my: "center"
          at: at
          target: obj
          adjust:
            method: "shift"
        style:
          classes: "ui-tooltip-tipsy ui-tooltip-mconf-label"
       mconf.Tooltip.create obj, options

$ ->
  mconf.Tooltip.bind()
