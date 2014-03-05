usersSelector = '#invite_users'
searchUsersUrl = '/users/select?limit=7'
startsOnSelector = '#invite_starts_on'
endsOnSelector = '#invite_ends_on'
durationSelector = '#invite_duration'
defaultDuration = 60*60 # 1h in secs
previousDuration = null

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
    formatSelection: (object, container) ->
      if object.name?
        object.name
      else
        object.text
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
    adjustEndOnStartChange()
    $end.setStartDate($start.getDate())
    storeDuration($start, $end)
    updateDuration()

  $(endsOnSelector).on 'changeDate', (val1, val2) ->
    # updates the date to ignore the seconds
    $end.setDate(ignoreSeconds($end.getDate()))
    adjustEndOnEndChange()
    storeDuration($start, $end)
    updateDuration()

# Stores the current duration in seconds
storeDuration = (start, end) ->
  previousDuration = (end.getDate() - start.getDate()) / 1000 # in secs

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

  # the end can never be before the start
  $end.setStartDate($start.getDate())

  # store the initial duration and update the label
  storeDuration($start, $end)
  updateDuration()

# Updates the text in the label with the duration using the start and end dates
# set in the inputs.
updateDuration = ->
  duration = previousDuration
  duration = ignoreSeconds(new Date(duration * 1000)).getTime()
  #duration = moment.duration(duration, "milliseconds")
  #text = duration.humanize()
  text = moment.utc(duration).format("HH:mm")

  $(durationSelector).text(text)

# Adjusts the end date according to the start date when the start date is changed
# by the user. The end can never be lower than the start date, and will also sometimes
# be automatically set to maintain the duration previously specified.
adjustEndOnStartChange = ->
  $end = $(endsOnSelector).data("datetimepicker")
  $start = $(startsOnSelector).data("datetimepicker")

  # setting a start to be after the end, makes the end jump forward and
  # keeps the previous duration (if any)
  if $end.getDate() < $start.getDate()
    if previousDuration?
      $end.setDate(addDuration($start.getDate(), previousDuration))
    else
      $end.setDate(addDuration($start.getDate(), defaultDuration))

  # always keep the previous duration if it is set
  else if previousDuration?
    $end.setDate(addDuration($start.getDate(), previousDuration))

  # no previous duration, use the default
  else
    $end.setDate(addDuration($start.getDate(), defaultDuration))

# Adjusts the end date according when the end date input is changed by the user.
adjustEndOnEndChange = (oldValue) ->
  $end = $(endsOnSelector).data("datetimepicker")
  $start = $(startsOnSelector).data("datetimepicker")

  # don't ever let the end be before the start
  if $end.getDate() < $start.getDate()
    $end.setDate($start.getDate())

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
