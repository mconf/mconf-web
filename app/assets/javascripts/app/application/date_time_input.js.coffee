# Javascript logic for date and time inputs.
# Uses the library bootstrap3-datetimepicker-rails to allow the user to select a date and
# the standard `<select>` tags rendered by rails to select a time.
# This component will bind these inputs together and provide methods to work with them as
# if they were a single input.
# Currently works for times with hours and minutes only, seconds are ignored.
#
# Examples:
#
# In your view, render the tags as in the example below:
#
#   %label= "Ends on"
#   #ends_on_date.input.input-append
#     %input{ :'data-format' => t('_other.datetimepicker.format'), :type => "text", :name => 'invite[ends_on]' }
#     %span.add-on
#       %i{ :class => "icon icon-calendar" }
#   %span= "at"
#   = f.input :ends_on_time, :label => false, :as => :time, :minute_step => 5, :prompt => { :hour => "", :minute => "" }, :id => "ends_on_time"
#
# In your javascript, create the DateTimeInput with:
#
#   dateInput = $("#ends_on_date")[0]
#   timeInput = $("#ends_on_time")[0]
#   startInput = new mconf.DateTimeInput(dateInput, timeInput)
#
# Triggers the following events:
# * `change`: when the date or time was changed
#
class mconf.DateTimeInput

  # `@dateInput` is the element in which the `datetimepicker` will be applied to.
  # `@timeInput` is the container of `<select>`s created by rails `f.input :as => :time`
  constructor: (@dateInput, @timeInput) ->
    $target = $(@dateInput)
    $target.datetimepicker
      language: I18n.locale
      pickTime: false
    @_setupEvents()

  # Sets the date `value` in the inputs in this component.
  setDate: (value) ->
    targetDate = moment(value)

    # first sets the date in the datetimepicker
    picker = @_getDateTimePicker()
    picker.setDate(value)

    # sets the hour in the hour <select>
    hoursInput = @_getHoursInput()
    hoursOption = @_getTimeOptionFor(hoursInput, targetDate.hours())
    if hoursOption? and hoursOption.length > 0
      hoursOption.prop("selected", true)
    else
      # selects the first option, the empty string
      hoursInput.children("option:first-child").prop("selected", true)

    # sets the minute in the minute <select>
    minutesInput = @_getMinutesInput()
    minutesOption = @_getTimeOptionFor(minutesInput, targetDate.minutes())
    if minutesOption? and minutesOption.length > 0
      minutesOption.prop("selected", true)
    else
      # selects the first option, the empty string
      minutesInput.children("option:first-child").prop("selected", true)

  # Returns the current date and time selected in this DateTimeInput.
  getDate: ->
    # get the date from the datetimepicker
    picker = @_getDateTimePicker()
    date = picker.getDate()

    # get the time from the <select>s
    date = moment(date)
    date.set("hour", @_getSelectedHours())
    date.set("minute", @_getSelectedMinutes())
    date.set("second", 0)
    date.set("millisecond", 0)

    date

  # Sets the minimum date the user is allowed to select in this DateTimeInput.
  # Will affect only the date, not the time!
  setMinDate: (value) ->
    date = moment(value)

    # since the minimum date will affect the date input only, we ignore the
    # time passed (consider it the beginning of the day)
    date.set("hour", 0)
    date.set("minute", 0)
    date.set("second", 0)
    date.set("millisecond", 0)

    picker = @_getDateTimePicker()
    picker.setMinDate(date)

  # TODO: we could use a simple js library to emit events
  on: (type, callback) ->
    @events.push({ type: type, callback: callback })
  # off: (type) ->

  # Setup the listeners to listen for events in the multiple inputs and trigger a single
  # event in this class.
  _setupEvents: ->
    @events = []
    @_getDateContainer().on "dp.change", =>
      for event in @events
        event.callback() if event.type is "change"
    @_getHoursInput().on "change", =>
      for event in @events
        event.callback() if event.type is "change"
    @_getMinutesInput().on "change", =>
      for event in @events
        event.callback() if event.type is "change"

  # Returns the container for the date element.
  _getDateContainer: ->
    $(@dateInput)

  # Returns the container for the time element.
  _getTimeContainer: ->
    $(@timeInput)

  # Returns the datetimepicker element.
  _getDateTimePicker: ->
    @_getDateContainer().data("DateTimePicker")

  # Returns the input (the `<select>`) used to select the hours.
  _getHoursInput: ->
    $found = null
    @_getTimeContainer().children().each ->
      if $(this).attr("name").match(/4i/)
        $found = $(this)
    return $found

  # Returns the input (the `<select>`) used to select the minutes.
  _getMinutesInput: ->
    $found = null
    @_getTimeContainer().children().each ->
      if $(this).attr("name").match(/5i/)
        $found = $(this)
    return $found

  # Returns the `<option>` tag inside `select` that contains a text closest
  # to `value`.
  _getTimeOptionFor: (select, value) ->
    option = null
    diff = null
    select.children("option").each ->
      currentValue = parseInt($(this).text())
      currentDiff = Math.abs(currentValue - value)

      # have to consider that `currentDiff` can be NaN and `diff` might
      # not have been set yet
      if _.isFinite(currentDiff) and (not diff? or currentDiff < diff)
        diff = currentDiff
        option = $(this)

    option

  # Returns an integer with the value of the hour currently selected.
  _getSelectedHours: ->
    hoursInput = @_getHoursInput()
    text = hoursInput.children("option:selected").text()
    parseInt(text)

  # Returns an integer with the value of the minute currently selected.
  _getSelectedMinutes: ->
    minutesInput = @_getMinutesInput()
    text = minutesInput.children("option:selected").text()
    parseInt(text)

# $ ->
#   mconf.DateTimeInput.bind()
