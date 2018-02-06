$ ->
  if isOnPage 'manage', 'statistics'
    uri = window.location.href

    if uri.indexOf("?") < 0
      $('.starts-at-wrapper .btn.all').addClass("active")
      $('.starts-at-wrapper .btn-group .btn.pick').removeClass("active")
    else
      $('.starts-at-wrapper .btn.all').removeClass("active")
      $('.starts-at-wrapper .btn-group .btn.pick').addClass("active")

    mconf.Resources.addToBind ->
      mconf.StatisticsFilter.bind()

    filterByDate()
    $('.starts-at-wrapper .btn-group .btn').on 'click', ->
      filterByDate(this)

    $('.starts-at-wrapper .btn.all').on 'click', ->
      window.location.replace(uri.substring(0, uri.indexOf("?")))

filterByDate = (el) ->
  if el
    selected = $(el).data('attr-value')
  else
    selected = $('.starts-at-wrapper .btn.all').data('attr-value')
