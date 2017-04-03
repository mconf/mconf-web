$ ->
  if isOnPage 'manage', 'recordings'

    showplay = ->
      $(".showplayback").on 'click', (e) ->
        $('.playback-types', $(this).parent().parent()).toggle(100)
        e.preventDefault()

    window.onpopstate = (event) ->
      window.location.href = mconf.Base.makeQueryString(event.state) if event.state
      event.state

    $('input.resource-filter-field').each ->
      field = $(this).attr('data-attr-filter')
      baseUrl = $('input.resource-filter').data('load-url')

      $(this).on 'click', ->
        url = new URL(window.location)
        params = mconf.Base.parseQueryString(url.search)
        if $(this).is(':checked')
          params[field] = $(this).val()
          opValue = if params[field] is 'true' then 'false' else 'true'
          opElement = $("input[data-attr-filter='#{field}'][value='#{opValue}']")[0]
          opElement.checked = false if opElement?.checked
        else
          delete params[field]

        url.search = mconf.Base.makeQueryString(params)
        history.pushState(params, '', url.toString())
        $('input.resource-filter').trigger('update-resources')

    showplay()
    mconf.Resources.addToBind showplay
