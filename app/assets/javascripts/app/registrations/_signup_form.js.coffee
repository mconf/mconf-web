#= require jquery/jquery.maskedinput

class mconf.SignupForm
  @setup: ->
    $fullname = $("[name='user[profile_attributes][full_name]']")
    $username = $("#user_username:not(.disabled)")
    $username.attr "value", mconf.Base.stringToSlug($username.val(), true)
    $username.on "input", () ->
      $username.val(mconf.Base.stringToSlug($username.val(), true))
    $username.on "blur", () ->
      $username.val(mconf.Base.stringToSlug($username.val(), false))
    $fullname.on "input keyup", ->
      $username.attr "value", mconf.Base.stringToSlug($fullname.val())

    $phone = $('#user_profile_attributes_phone:not(disabled)')
    $phone.mask("(99) 99999-999?9")

    $zipcode = $('#user_profile_attributes_zipcode:not(disabled)')
    $zipcode.mask("99999-999");

    $cpfcnpj = $('#user_profile_attributes_cpf_cnpj:not(disabled)')
    $cpfcnpj.mask("99999999999?999",{placeholder:" "})

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
