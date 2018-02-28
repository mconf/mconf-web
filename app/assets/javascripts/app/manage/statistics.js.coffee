$ ->
  if isOnPage 'manage', 'statistics'
    uri = window.location.href

    mconf.Resources.addToBind ->
      mconf.StatisticsFilter.bind()

    # only kept here because this link is inside a .btn-group that disables the default
    # click in the button, so we have to do the redirect it manually
    $('#statistics-filters .btn.all').on 'click', ->
      window.location.replace($(this).attr('href'))
