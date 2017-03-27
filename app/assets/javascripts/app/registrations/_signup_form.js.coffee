class mconf.SignupForm
  @setup: ->
    $fullname = $("#user__full_name:not(.disabled)")
    $username = $("#user_username:not(.disabled)")
    $username.attr "value", mconf.Base.stringToSlug($fullname.val())
    $fullname.on "input keyup", () ->
      $username.attr "value", mconf.Base.stringToSlug($fullname.val())

    $terms = $("#user_terms:not(.disabled)")
    $button = $("input[name='commit']")
    $terms.on 'change', (e) ->
      $button.prop('disabled', !$terms.is(":checked"));

    $usage_select = $("#user__service_usage_select:not(.disabled)")
    $usage = $(".user__service_usage:not(.disabled)")
    $usage_select.on 'change', (e) ->
      if ($usage_select.find('option:selected').val() == "Other")
        $usage.show(500)
      else
        $usage.hide(200)
