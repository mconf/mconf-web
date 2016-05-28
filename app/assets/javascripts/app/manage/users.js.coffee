#= require "../users/new"

$ ->
  if isOnPage 'manage', 'users'
    mconf.Resources.addToBind ->
      mconf.Users.New.bind()

    window.onpopstate = (event) ->
      window.location.href = mconf.Base.urlFromParts(event.state)
      event.state

    $('.search-filter-option .btn').each ->
      input = $(this)
      field = $(this).attr('data-attr-filter')
      value = $(this).attr('data-attr-value')
      baseUrl = $('input.resource-filter').data('load-url')

      $(this).on 'click', (e) ->
        e.preventDefault()
        params = mconf.Base.getUrlParts(String(window.location))

        if !$(this).hasClass('active')
          $(".search-filter-option .btn[data-attr-filter='#{field}']").removeClass('active')
          params[field] = value
          opValue = if params[field] is 'true' then 'false' else 'true'
          opElement = $("input[data-attr-filter='#{field}'][value='#{opValue}']")[0]
          opElement.checked = false if opElement?.checked
          $(this).addClass('active')
        else
          delete params[field]
          $(this).removeClass('active')
          $(this).blur()

        history.pushState(params, '', baseUrl + mconf.Base.urlFromParts(params))
        $('input.resource-filter').trigger('update-resources')
