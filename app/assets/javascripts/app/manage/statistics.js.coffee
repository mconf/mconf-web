$ ->
  if isOnPage 'manage', 'statistics'
    uri = window.location.href

    if uri.indexOf("?") < 0
      $('.starts-at-wrapper .btn.all').addClass("active")
    else
      $('.starts-at-wrapper .btn-group .btn').addClass("active")

    mconf.Resources.addToBind ->
      mconf.StatisticsFilter.bind()

    filterByDate()
    $('.starts-at-wrapper .btn-group .btn').on 'click', ->
      filterByDate(this)

    $('.starts-at-wrapper .btn.all').on 'click', ->
      window.location.replace(uri.substring(0, uri.indexOf("?")))

isAllSelected = ->
  selected = $('.starts-at-wrapper .btn.all').data('attr-value')
  selected is 0

filterByDate = (el) ->
  if el
    selected = $(el).data('attr-value')
  else
    selected = $('.starts-at-wrapper .btn.all').data('attr-value')
