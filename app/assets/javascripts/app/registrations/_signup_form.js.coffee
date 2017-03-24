class mconf.SignupForm
  @setup: ->
    $fullname = $("#user__full_name:not(.disabled)")
    $username = $("#user_username:not(.disabled)")
    $username.attr "value", mconf.Base.stringToSlug($fullname.val())
    $fullname.on "input keyup", () ->
      $username.attr "value", mconf.Base.stringToSlug($fullname.val())

    $terms = $("#user_terms:not(.disabled)")
    $button = $("input[name='commit']")
    $terms.on 'click', (e) ->
      $button.prop('disabled', !$terms.is(":checked"));
