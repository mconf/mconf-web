class mconf.StatisticsFilter

  @bind: ->
    start = $(statistics_starts_on_time)
    end = $(statistics_ends_on_time)
    mconf.DateTimeInput.setDate(start, new Date())
    mconf.DateTimeInput.setStartDate(start, new Date())
    mconf.DateTimeInput.setDate(end, new Date())
    mconf.DateTimeInput.setStartDate(end, new Date())

    filterByDate()
    $('.starts-at-wrapper .btn-group .btn').on 'click', ->
      filterByDate(this)

    # when submitting, set the starts on date to now, so that
    # 'now' means when the user submitted the form
    $('form', '#manage').on 'submit', ->
      setStartsOnToAll() if isAllSelected()
      console.log("oi")

isAllSelected = ->
  selected = $('.starts-at-wrapper .btn.active').data('attr-value')
  selected is 0

filterByDate = (el) ->
  setStartsOnToAll()

  if el
    selected = $(el).data('attr-value')
  else
    selected = $('.starts-at-wrapper .btn.active').data('attr-value')
  if selected is 0
    $(statistics_starts_on_time).parent().hide()
    $(statistics_ends_on_time).parent().hide()
  else
    $(statistics_starts_on_time).parent().show()
    $(statistics_ends_on_time).parent().show()
    $(statistics_starts_on_time).focus()

setStartsOnToAll = ->
  mconf.DateTimeInput.setDate($(statistics_starts_on_time), new Date())
