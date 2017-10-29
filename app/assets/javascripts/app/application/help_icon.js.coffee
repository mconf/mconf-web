# Help icons show hints for e.g. inputs in a form.
class mconf.HelpIcon

  hintOptions =
    placement: 'auto top'
    title: ->
      formGroup = $(this).parents(".form-group")
      formGroup.find(".help-block").text()

  @bindIcon: (el) ->
    hintOptions = _.extend(mconf.Tooltip.defaultOptions, hintOptions)
    unless $(el).children('.icon-help').length > 0
      help = $("<i class='fa fa-question-circle-o icon icon-help'></i>")
      $(el).append(help)
      $(el).find(".icon-help").tooltip(hintOptions)

  @bind: ->
    $(".form-group.has-hint > label").each ->
      mconf.HelpIcon.bindIcon(this)
    $("span.has-hint > label").each ->
      mconf.HelpIcon.bindIcon(this)
    $(".form-group.has-hint > .checkbox").each ->
      mconf.HelpIcon.bindIcon(this)

$ ->
  mconf.HelpIcon.bind()
