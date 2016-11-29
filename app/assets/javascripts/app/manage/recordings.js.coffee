$ ->

  showplay = ->
    $(".showplayback").on 'click', (e) ->
      $('.playback-types', $(this).parent().parent()).toggle(100)
      e.preventDefault()

  if isOnPage 'manage', 'recordings'
    showplay()
    mconf.Resources.addToBind showplay

    $('input.resource-filter-field').each ->
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
