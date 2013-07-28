metadataFieldsTemplate = HandlebarsTemplates['custom_bigbluebutton_rooms/room_metadata']

$(document).ready ->
  if isOnPage 'custom_bigbluebutton_rooms', 'edit|new'
    setupMetadata()

setupMetadata = ->
  $("#room-metadata-add").on "click", (e) ->
    addMetadataFields()
    e.preventDefault()
  $(document).on "click", ".room-metadata-remove", (e) ->
    removeMetadataFields(e)
    e.preventDefault()

addMetadataFields = () ->
  currentCount = parseInt($("#room-metadata").attr("data-metadata-count"))
  params =
    id: currentCount
    label_name: I18n.t('activerecord.attributes.bigbluebutton_metadata.name')
    label_content: I18n.t('activerecord.attributes.bigbluebutton_metadata.content')
  $("#room-metadata").append(metadataFieldsTemplate(params))
  $("#room-metadata").attr("data-metadata-count", currentCount+1)

removeMetadataFields = (e) ->
  target = $(e.target)
  target.parents(".room-metadata-field").remove()
  # don't update the metadata count, we can just keep incrementing the number
  # when adding more metadata fields and it will work
