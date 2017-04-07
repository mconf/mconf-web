class mconf.SignupForm
  @setup: ->
    $fullname = $("[name='user[profile_attributes][full_name]']")
    $username = $("[name='user[username]']")
    $username.attr "value", mconf.Base.stringToSlug($fullname.val())
    $fullname.on "input keyup", ->
      $username.attr "value", mconf.Base.stringToSlug($fullname.val())

    submitToggle = ->
      $button.prop('disabled', !$terms.is(":checked"));

    $terms = $("#terms")
    $button = $("input[name='commit']")
    submitToggle()
    $terms.on 'change', (e) ->
      submitToggle()

    $usageSelect = $("#service_usage_select")
    $usage = $("#user_profile_attributes_service_usage")
    $usageSelect.on 'change', (e) ->
      last = $('option:last-child', $usageSelect).val()
      selected = $usageSelect.find(':selected').val()
      if selected is last
        $usage.val(null)
        $usage.show(500)
        $usage.focus()
      else
        $usage.hide(200)
        $usage.val(selected)
