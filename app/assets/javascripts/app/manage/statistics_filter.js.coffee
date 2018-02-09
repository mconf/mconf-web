submitSelector = 'input[type=\'submit\']'

class mconf.StatisticsFilter

  @bind: ->
    start = $(statistics_starts_on_time)
    end = $(statistics_ends_on_time)
    mconf.DateTimeInput.setStartDate(start, new Date('2010-01-01'))

    filterByDate()
    $('.starts-at-wrapper .btn-group .btn').on 'click', ->
      filterByDate(this)

    $('.datetime-picker-input').on 'change', ->
      checkDate()

    start.on 'change', ->
      limitMinimumEnd()

    end.on 'change', ->
      limitMaximumStart()

filterByDate = (el) ->
  if el
    selected = $(el).data('attr-value')
  else
    selected = $('.starts-at-wrapper .btn.active').data('attr-value')

limitMinimumEnd = ->
  startDate = statistics_starts_on_time.value

  if  startDate != ""
    mconf.DateTimeInput.setStartDate($(statistics_ends_on_time), new Date(startDate))

limitMaximumStart = ->
  endDate = statistics_ends_on_time.value

  if  endDate != ""
    mconf.DateTimeInput.setEndDate($(statistics_starts_on_time), new Date(endDate))

checkDate = ->
  startDate = statistics_starts_on_time.value
  endDate = statistics_ends_on_time.value

  $(submitSelector).removeAttr('disabled')
