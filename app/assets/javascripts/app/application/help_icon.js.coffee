# Help icons show hints for e.g. inputs in a form.
class mconf.HelpIcon

  hintOptions =
    placement: 'auto top'
    title: ->
      formGroup = $(this).parents(".form-group")
      formGroup.find(".help-block").text()

  @bind: ->
    hintOptions = _.extend(mconf.Tooltip.defaultOptions, hintOptions)

    $(".form-group.has-hint > label").each ->
      unless $(this).children('.icon-mconf-help').length > 0
        help = $("<i class='fa fa-question-circle-o icon-awesome icon-mconf-help'></i>")
        $(this).append(help)
        $(this).find(".icon-mconf-help").tooltip(hintOptions)

    $(".form-group.has-hint > .checkbox").each ->
      unless $(this).children('.icon-mconf-help').length > 0
        help = $("<i class='fa fa-question-circle-o icon-awesome icon-mconf-help'></i>")
        $(this).append(help)
        $(this).find(".icon-mconf-help").tooltip(hintOptions)

$ ->
  mconf.HelpIcon.bind()
