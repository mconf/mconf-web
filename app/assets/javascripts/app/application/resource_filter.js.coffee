# An input to filter results in a view, usually in an index page.
# Will submit the text from the input to a given URL (the text is set in a parameter `q` in the URL),
# get the HTML in the response and update the target div with its content.
#
# Examples:
#
# The text input to filter the results:
#   = text_field_tag :users_filter_text, params[:q], :'data-load-url' => manage_users_path(:partial => 1), :'data-target' => '#users-list', :class => 'resource-filter'
#
# The controller that receives this call has to check for `params[:partial]` and render a
# partial if this param is set.

# local configuration variables
namespace = "mconfResourceFilter"
# small delay before searching to reduce the # of requests, in ms
searchDelay = 300
showTime = 0

class mconf.ResourceFilter

  @bind: ->
    $("input.resource-filter").each ->

      # the target input
      $input = $(this)
      # the element where the results will be put
      $target = $($input.attr("data-target"))

      timeout = null
      $input.off "keyup.#{namespace}"
      $input.on "keyup.#{namespace}", ->
        clearTimeout(timeout)
        timeout = setTimeout(updateResources, searchDelay, $input, $target)

      # custom events to update the resources
      $input.off "update-resources.#{namespace}"
      $input.on "update-resources.#{namespace}", ->
        clearTimeout(timeout)
        timeout = setTimeout(updateResources, searchDelay, $input, $target, true)

      # finds the input where the total number of resources should be shown,
      # configures it, and displays it
      $filter = $($input.data("filter"))
      if $filter.length > 0
        $(".resource-filter-without-text", $filter).hide()
        $(".resource-filter-with-text", $filter).hide()
        text = $input.val()
        if text?.length
          $(".resource-filter-value", $filter).text(text)
          $(".resource-filter-without-text", $filter).hide(showTime)
          $(".resource-filter-with-text", $filter).show(showTime)
        else
          $(".resource-filter-with-text", $filter).hide(showTime)
          $(".resource-filter-without-text", $filter).show(showTime)

# Fetches the resources and updates the page
updateResources = ($input, $target, force = false) ->
  searchQuery = $input.val()

  # store the latest search query in the element
  lastValue = $input.attr("data-last-value")
  $input.attr("data-last-value", searchQuery)

  if force or (searchQuery isnt lastValue)

    # adjust the params in the URL
    params = mconf.Base.getUrlParts(String(window.location))
    if searchQuery?.length > 0
      params.q = encodeURIComponent(searchQuery)
    else
      delete params.q
    url = $input.attr("data-load-url") + mconf.Base.urlFromParts(params)
    history.replaceState(params, '', url)

    # load the resources and update the page
    $target.load url, ->
      mconf.Resources.bind()

$ ->
  mconf.ResourceFilter.bind()
