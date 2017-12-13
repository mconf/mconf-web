class mconf.UserEdit
  @setup: ->
    $slug = $("#bigbluebutton_room_slug:not(.disabled)")
    $slug.attr "value", mconf.Base.stringToSlug($slug.val(), true)
    $slug.on "input", () ->
      $slug.val(mconf.Base.stringToSlug($slug.val(), true))
    $slug.on "blur", () ->
      $slug.val(mconf.Base.stringToSlug($slug.val(), false))

    visibilityChanged()
    $('.room-visibility .btn-group .btn').on 'click', ->
      visibilityChanged(this)

visibilityChanged = (el) ->
  if el
    selected = $(el).data('attr-value')
  else
    selected = $('.room-visibility-options .btn.active').data('attr-value')
  if selected is 0
    $('#bigbluebutton_room_private').val(0)
    $('.form-group.bigbluebutton_room_attendee_key').hide()
    $('.form-group.bigbluebutton_room_attendee_key input').attr('disabled', true)
  else
    $('#bigbluebutton_room_private').val(1)
    $('.form-group.bigbluebutton_room_attendee_key').show()
    $('.form-group.bigbluebutton_room_attendee_key input').attr('disabled', null)
