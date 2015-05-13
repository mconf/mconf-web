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
      baseUrl = $('input.resource-filter').data('load-url')

      $(this).on 'click', ->
        params = mconf.Base.getUrlParts(String(window.location))
        if $(this).is(':checked')
          params[field] = $(this).val()
          opValue = if params[field] is 'true' then 'false' else 'true'
          opElement = $("input[data-attr-filter='#{field}'][value='#{opValue}']")[0]
          opElement.checked = false if opElement?.checked
        else
          delete params[field]

        history.pushState(params, '', baseUrl + mconf.Base.urlFromParts(params))
        $('input.resource-filter').trigger('update-resources')
