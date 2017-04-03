$ ->
  if isOnPage('events', 'new|create|edit|update')

    # Calendar
    setup_datetimepicker = (id) ->
      $(id).datetimepicker
        language: $(id).attr('data-date-locale') || 'en'
        showToday: true
        pickTime: false

    setup_datetimepicker '#start_on_date'
    setup_datetimepicker '#end_on_date'

    # Make respective buttons clear their fields
    $('.clear-date').on 'click', (e) ->
      targets = $(this).attr('data-clear').split(",")
      targets.forEach (target) ->
        $("#event_#{target.trim()}").val('')
        $("#event_#{target.trim()}_#{n}i").val('00') for n in [1..5]

    # Time zone
    $("#event_time_zone").select2
      width: "50%"

    # Description editor box
    opts =
      button: false
      autogrow:
        minHeight: 150
        maxHeight: 300
      button:
        preview: true
        fullscreen: false
        bar: true

    editor = new EpicEditor(opts).load()
    editor.importFile('epiceditor', $('#event_description').text())

    $("#event_description").hide()

    editor.on 'update', ->
      $('#event_description').text(editor.exportFile())

    window.onresize = ->
      editor.reflow()
