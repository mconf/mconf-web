# We use tooltips from bootstrap, so all we have to do is associate the proper elements
# calling bootstrap's `tooltip()`.
class mconf.Tooltip

  defaultOptions =
    # append tooltips to the <body> element to prevent problems with tooltips inside
    # elements with `overflow:hidden` set, for example.
    container: 'body'
    placement: 'auto top'

  @bind: ->
    $("a[rel=popover]").popover()
    $(".tooltip").tooltip(defaultOptions)
    $(".tooltipped").tooltip(defaultOptions)
    $("a[rel=tooltip]").tooltip(defaultOptions)

    # hints in form inputs are shown as tooltips
    hintOptions =
      title: ->
        formGroup = $(this).parent()
        formGroup.children(".help-block").text()
    hintOptions = _.extend(defaultOptions, hintOptions)
    $(".form-group.has-hint > label.control-label").tooltip(hintOptions)


$ ->
  mconf.Tooltip.bind()
