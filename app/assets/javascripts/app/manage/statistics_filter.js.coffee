submitSelector = 'input[type=\'submit\']'
container = '#statistics_filter'
startsOnSelector = '#statistics_starts_on'
endsOnSelector = '#statistics_ends_on'
startsTimeSelector = '.statistics_starts_on_time'
endsTimeSelector = '.statistics_ends_on_time'

class mconf.StatisticsFilter

  @bind: ->
    inputStartDate = $(startsOnSelector, container)[0]
    inputEndDate = $(endsOnSelector, container)[0]
    inputStartTime = $(startsTimeSelector, container)[0]
    inputEndTime = $(endsTimeSelector, container)[0]

    inputStartTime.hidden = true
    inputEndTime.hidden = true

    if inputStartDate && inputEndDate

      @startInput = new mconf.DateTimeInput(inputStartDate, inputStartTime)
      @endInput = new mconf.DateTimeInput(inputEndDate, inputEndTime)

      @_initializeDates()

      @startInput.on "change", =>
        @_adjustEndOnStartChange()
        @endInput.setMinDate(@startInput.getDate())

      @endInput.on "change", =>
        @_adjustEndOnEndChange()
        @startInput.setMaxDate(@endInput.getDate())

  # Initialize the dates with default values
  @_initializeDates: ->

    start = new Date()
    end = new Date()

    # start at the current time
    @startInput.setDate(start)

    @endInput.setDate(end)

    # the end can never be before the start
    @endInput.setMinDate(@startInput.getDate())

    # the start can never be after the end
    @startInput.setMaxDate(@endInput.getDate())

  # Adjusts the end date according to the start date when the start date is changed
  # by the user. The end can never be lower than the start date
  @_adjustEndOnStartChange: ->

    # setting a start to be after the end, makes the end jump forward and
    # keeps the previous duration (if any)
    if @endInput.getDate() < @startInput.getDate()
      @endInput.setDate(@startInput.getDate())

  # Adjusts the end date according when the end date input is changed by the user.
  @_adjustEndOnEndChange: ->

    # don't ever let the end be before the start
    if @endInput.getDate() < @startInput.getDate()
      @endInput.setDate(@startInput.getDate())

@getEndDateTimePicker = ->
  $(endsOnSelector).data("DateTimePicker")

@getStartDateTimePicker = ->
$(startsOnSelector).data("DateTimePicker")
