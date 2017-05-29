# TODO: the search is exactly like we do at manage/users.js, should be a common component
$ ->
  if isOnPage 'manage', 'recordings'

    window.onpopstate = (event) ->
      window.location.href = mconf.Base.urlFromParts(event.state)
      event.state

    $('.search-filter-option .btn').each ->
      input = $(this)
      field = $(this).attr('data-attr-filter')
      value = $(this).attr('data-attr-value')
      baseUrl = $('input.resource-filter').data('load-url')

      $(this).on 'click', ->
        url = new URL(window.location)
        params = mconf.Base.parseQueryString(url.search)

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

        url.search = mconf.Base.makeQueryString(params)
        history.pushState(params, '', url.toString())
        $('input.resource-filter').trigger('update-resources')

#   showplay = ->
#     $(".showplayback").on 'click', (e) ->
#       $('.playback-types', $(this).parent().parent()).toggle(100)
#       e.preventDefault()

