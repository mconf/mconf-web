class mconf.NewSpaceForm
  @setup: ->
    $name = $("#space_name")
    $permalink = $("#space_permalink")
    $permalink.attr "value", mconf.Base.stringToSlug($name.val())
    $name.on "input keyup", () ->
      $permalink.attr "value", mconf.Base.stringToSlug($name.val())

$ ->
  if isOnPage 'spaces', 'new|create'
    mconf.NewSpaceForm.setup()
