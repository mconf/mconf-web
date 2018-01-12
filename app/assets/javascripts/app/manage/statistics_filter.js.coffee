class mconf.StatisticsFilter

  @bind: ->
    start = $(statistics_starts_on_time)
    end = $(statistics_ends_on_time)

    filterByDate()
    $('.starts-at-wrapper .btn-group .btn').on 'click', ->
      filterByDate(this)

    $('.datetime-picker-input').on 'click', ->
      checkDate()

isAllSelected = ->
  selected = $('.starts-at-wrapper .btn.active').data('attr-value')
  selected is 0

filterByDate = (el) ->

  if el
    selected = $(el).data('attr-value')
    console.log(selected)
  else
    selected = $('.starts-at-wrapper .btn.active').data('attr-value')

checkDate = ->
  console.log("vo chora")
  startDate = statistics_starts_on_time.value
  endDate = statistics_ends_on_time.value

  $('btn-primary').data('disabled', false)

  console.log(startDate)
  console.log(endDate)
  if  startDate != "" && endDate != ""
    console.log("aqui entrou")
    if startDate < endDate
      console.log("OLA")
