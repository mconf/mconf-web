#= require "../users/new"

$ ->
  if isOnPage 'manage', 'users'
    mconf.Resources.addToBind ->
      mconf.Users.New.bind()

    window.onpopstate = (event) ->
      window.location.href = mconf.Base.urlFromParts(event.state)
      event.state

    $('input.resource-filter-field').each ->
      input = $(this)
      field = $(this).attr('data-attr-filter')
      base_url = '/manage/users/'

      $(this).click ->
        params = mconf.Base.getUrlParts(String(window.location))
        if $(this).is(':checked')
          params[field] = $(this).val()

          op_value = if (params[field] == 'true') then 'false' else 'true'
          op_element = $("input[data-attr-filter='#{field}'][value='#{op_value}']")[0]

          if op_element.checked
            op_element.checked = false

        else
          delete params[field]

        history.pushState(params, '', base_url + mconf.Base.urlFromParts(params))
        $('input.resource-filter').trigger('keyup.mconfResourceFilter')

