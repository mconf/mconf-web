$ ->
  if isOnPage 'manage', 'statistics'

    mconf.Resources.addToBind ->
      mconf.StatisticsFilter.bind()

    filterByDate()
    $('.starts-at-wrapper .btn-group .btn').on 'click', ->
      filterByDate(this)

isAllSelected = ->
  selected = $('.starts-at-wrapper .btn.active').data('attr-value')
  selected is 0

filterByDate = (el) ->

  if el
    selected = $(el).data('attr-value')
  else
    selected = $('.starts-at-wrapper .btn.active').data('attr-value')
