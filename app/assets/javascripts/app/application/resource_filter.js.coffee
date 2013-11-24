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

updateResources = ($input, $target) ->
  text = $input.val()
  lastValue = $input.attr("data-last-value")

  if text isnt lastValue
    $input.attr("data-last-value", text)
    url = $input.attr("data-load-url") + "&q=#{text}"
    $target.load url, ->
      mconf.Resources.bind()

$ ->
  mconf.ResourceFilter.bind()
