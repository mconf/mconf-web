$ ->
  if isOnPage('custom_bigbluebutton_servers', 'show')
    bindRecordingEvents()
    updateLink($("#server-recordings-fetch"))
    updateLink($("#server-recordings-publish"))
    updateLink($("#server-recordings-unpublish"))

bindRecordingEvents = ->
  $("#server-recordings-fetch").on "keyup change", ->
    updateLink(this)
  $("#server-recordings-publish").on "keyup change", ->
    updateLink(this)
  $("#server-recordings-unpublish").on "keyup change", ->
    updateLink(this)

# Update a link that's related to the input in `element` using the text
# inside the input.
updateLink = (element) ->
  filters = $(element).val()
  url = $(element).attr("data-base-url")
  unless _.isEmpty(filters.trim())
    url = url + "?" + filters
  id = $(element).attr("id")
  target = $("[data-link-for=#{id}]")
  target.attr("href", url)
