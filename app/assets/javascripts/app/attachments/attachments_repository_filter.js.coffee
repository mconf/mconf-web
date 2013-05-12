
# Global variables

#in mixed filter
filtered_title = null
filtered_author = null
filtered_type = null
filtered_any = null

#in event filter
filtered_event = null

# Show attachments according to global filtered_* variables
filter_attachments = ->
  $("tr.ui-collection-result").each ->
    if (not filtered_title? or $(this).children("td.attachment-name").children("a").text().toLowerCase().search(filtered_title.toLowerCase()) >= 0) and (not filtered_author? or $(this).children("td.attachment-author").children("a").text().toLowerCase().search(filtered_author.toLowerCase()) >= 0) and (not filtered_type? or $(this).children("td.attachment-name").attr("rel") is filtered_type) and (not filtered_any? or $(this).children("td.attachment-name").children("a").text().toLowerCase().search(filtered_any.toLowerCase()) >= 0 or $(this).children("td.attachment-author").children("a").text().toLowerCase().search(filtered_any.toLowerCase()) >= 0) and (not filtered_event? or $(this).attr("rel") is filtered_event)
      $(this).css "display", ""
    else
      $(this).hide()



#Mixed filter event listeners
$("#title_filter").livequery "keyup", ->
  filtered_title = @value
  filter_attachments()

$("#author_filter").livequery "keyup", ->
  filtered_author = @value
  filter_attachments()

$("#any_field_filter").livequery "keyup", ->
  filtered_any = @value
  filter_attachments()

$("#type_filter").livequery "change", ->
  filtered_type = (if $(this).val() is "" then null else $(this).val())
  filter_attachments()

$("#mix_filter").livequery "change", ->
  filtered_title = null
  filtered_author = null
  filtered_type = null
  filtered_any = null
  $(".mixed_alternative").hide()
  $("#" + $(this).val()).val("").show()
  filter_attachments()


#Event filter event listener
$("#event_select").livequery "change", ->
  filtered_event = (if $(this).val() is "" then null else "event_" + $(this).val())
  filter_attachments()

