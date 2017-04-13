# Javascript logic for date and time inputs.
# Uses the library bootstrap-datetimepicker to allow the user to select a date and a time.
# Currently works for times with hours and minutes only, seconds are ignored.
#
# Works together with the custom simple_form input DatetimePickerInput.
class mconf.DateTimeInput

  @bind: ->
    # @unbind()

    $(".datetime-picker-input").each ->
      $picker = $('input', this)
      $picker.attr('readonly', 'readonly')
      $picker.datetimepicker
        format: $picker.data('format')
        autoclose: true
        todayHighlight: true
        fontAwesome: true
        maxView: 3 # year
        language: $picker.data('language')
        timezone: $picker.data('timezone')
        pickerPosition: 'bottom-left'

      $('i', this).on 'click', ->
        $picker.datetimepicker('show')

  @setDate: (element, date) ->
    getDatetimePickerTarget(element).datetimepicker('update', date)

  @setStartDate: (element, date) ->
    getDatetimePickerTarget(element).datetimepicker('setStartDate', date)

  @show: (element) ->
    getDatetimePickerTarget(element).datetimepicker('show')

  @hide: (element) ->
    getDatetimePickerTarget(element).datetimepicker('hide')

getDatetimePickerTarget = (element) ->
  if $(element).is('input')
    $(element)
  else
    $('input', element)

$ ->
  mconf.DateTimeInput.bind()
