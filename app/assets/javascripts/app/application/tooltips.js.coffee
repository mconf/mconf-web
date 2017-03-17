# We use tooltips from bootstrap, so all we have to do is associate the proper elements
# calling bootstrap's `tooltip()`.
class mconf.Tooltip

  defaultOptions =
    # append tooltips to the <body> element to prevent problems with tooltips inside
    # elements with `overflow:hidden` set, for example.
    container: 'body'
    placement: 'auto top'
    delay:
      show: 500
      hide: 100

  @bind: ->
    $("a[rel=popover]").popover()
    $(".tooltip").tooltip(defaultOptions)
    $(".tooltipped").tooltip(defaultOptions)
    $("a[rel=tooltip]").tooltip(defaultOptions)

    # hints in form inputs are shown as tooltips
    hintOptions =
      placement: 'auto top'
      title: ->
        formGroup = $(this).parents(".form-group")
        formGroup.find(".help-block").text()
    hintOptions = _.extend(defaultOptions, hintOptions)

    $(".form-group.has-hint > label").each ->
      help = $("<i class='fa fa-question-circle-o icon-awesome icon-mconf-help'></i>")
      $(this).append(help)
      $(this).find(".icon-mconf-help").tooltip(hintOptions)

    $(".form-group.has-hint > .checkbox").each ->
      help = $("<i class='fa fa-question-circle-o icon-awesome icon-mconf-help'></i>")
      $(this).append(help)
      $(this).find(".icon-mconf-help").tooltip(hintOptions)

$ ->
  mconf.Tooltip.bind()
