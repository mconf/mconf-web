usersSelector = '#invite_users'
searchUsersUrl = '/users/select'
startsOnSelector = '#invite_starts_on'
endsOnSelector = '#invite_ends_on'
durationSelector = '#invite_duration'
defaultDuration = 60*60 # 1h in secs
previousStartDate = null

mconf.CustomBigbluebuttonRooms or= {}

class mconf.CustomBigbluebuttonRooms.Invitation

  @bind: ->
    bindUsers()
    bindDates()

  @unbind: ->
    # TODO: can it be done?

bindUsers = ->
  $(usersSelector).select2
    minimumInputLength: 1
    width: 'resolve'
    multiple: true
    formatSearching: -> I18n.t('invite_people.users.searching')
    formatInputTooShort: -> I18n.t('invite_people.users.hint')
    tags: true
    tokenSeparators: [",", ";"]
    createSearchChoice: (term, data) ->
      if mconf.Base.validateEmail(term)
        { id: term, text: term }
    ajax:
      url: searchUsersUrl
      dataType: "json"
      data: (term, page) ->
        q: term # search term
      results: (data, page) -> # parse the results into the format expected by Select2.
        results: data

bindDates = ->
  $("#{startsOnSelector}, #{endsOnSelector}").datetimepicker
    language: I18n.locale
    pickSeconds: false

  initializeDates()

  $end = $(endsOnSelector).data("datetimepicker")
  $start = $(startsOnSelector).data("datetimepicker")

  $(startsOnSelector).on 'changeDate', (date, oldDate) ->
    # updates the date to ignore the seconds
    $start.setDate(ignoreSeconds($start.getDate()))
    adjustEndDate()
    $end.setStartDate($start.getDate())
    updateDuration()
    previousStartDate = $start.getDate()

  $(endsOnSelector).on 'changeDate', ->
    # updates the date to ignore the seconds
    $end.setDate(ignoreSeconds($end.getDate()))
    adjustEndDate()
    $start.setEndDate($end.getDate())
    updateDuration()

# Initialize the dates with default values
initializeDates = ->
  $end = $(endsOnSelector).data("datetimepicker")
  $start = $(startsOnSelector).data("datetimepicker")

  # uses the current time, adjusting to the local timezone (datetimepicker expects UTC)
  now = moment()
  zone = now.zone()
  start = now.utc().toDate().getTime() - (zone * 60000)
  start = ignoreMinutes(new Date(start))
  $start.setDate(start)
  $end.setDate(addDuration(start, defaultDuration))

  updateDuration()

# Updates the text in the label with the duration using the start and end dates
# set in the inputs.
updateDuration = ->
  $end = $(endsOnSelector).data("datetimepicker").getDate()
  $start = $(startsOnSelector).data("datetimepicker").getDate()
  duration = moment($end).toDate().getTime() - moment($start).toDate().getTime()
  duration = ignoreSeconds(new Date(duration)).getTime()
  duration = moment.duration(duration, "milliseconds")
  text = duration.humanize()
  $(durationSelector).text(text)

# Adjusts the end date according to the start date. The end can never be lower
# than the start date, and will also sometimes be automatically set to maintain
# the duration previously specified.
adjustEndDate = ->
  $end = $(endsOnSelector).data("datetimepicker")
  $start = $(startsOnSelector).data("datetimepicker")

  # end cannot be before start
  if $end.getDate() < $start.getDate()
    $end.setDate(addDuration($start.getDate(), defaultDuration))

  # maintain the duration previously selected
  else if previousStartDate?
    endSecs = Math.floor($end.getDate().getTime() / 60000)
    startSecs = Math.floor(previousStartDate.getTime() / 60000)
    duration = (endSecs - startSecs) * 60
    $end.setDate(addDuration($start.getDate(), duration))

  # no previous duration, use the default
  else
    $end.setDate(addDuration($start.getDate(), defaultDuration))

# Adds 'duration' seconds to a Date object 'date'.
addDuration = (date, duration) ->
  moment(date).add(duration, 'seconds').toDate()

# Nullifies the seconds and milliseconds on a Date object
ignoreSeconds = (date) ->
  time = Math.floor(date.getTime() / 60000) * 60000
  new Date(time)

# Nullifies the minutes, seconds and milliseconds on a Date object
ignoreMinutes = (date) ->
  time = Math.floor(date.getTime() / 3600000) * 3600000
  new Date(time)
