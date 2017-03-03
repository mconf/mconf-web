class mconf.UserEdit
  @setup: ->
    $param = $("#bigbluebutton_room_param:not(.disabled)")
    $param.attr "value", mconf.Base.stringToSlug($param.val(), true)
    $param.on "input", () ->
      $param.val(mconf.Base.stringToSlug($param.val(), true))
    $param.on "blur", () ->
      $param.val(mconf.Base.stringToSlug($param.val(), false))
