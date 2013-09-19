# We use tooltips from bootstrap, so all we have to do is associate the proper elements
# calling bootstrap's `tooltip()`.
class mconf.Tooltip

  defaultOptions =
    # append tooltips to the <body> element to prevent problems with tooltips inside
    # elements with `overflow:hidden` set, for example.
    container: 'body'
    placement: 'top'

  @bind: ->
    $("a[rel=popover]").popover()
    $(".tooltip").tooltip(defaultOptions)
    $(".tooltipped").tooltip(defaultOptions)
    $("a[rel=tooltip]").tooltip(defaultOptions)

$ ->
  mconf.Tooltip.bind()
