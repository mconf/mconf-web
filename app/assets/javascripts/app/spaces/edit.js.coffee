$ ->
  if isOnPage 'spaces', 'edit'
    updatePasswords($('input#space_public').is(':checked'))
    $('input#space_public').on 'click', -> updatePasswords($(this).is(':checked'))

    uploaderCallbacks =
      onComplete: mconf.Crop.onUploadComplete

    mconf.Uploader.bind
      callbacks: uploaderCallbacks


    # select input to search for spaces
    $("#tag_list").select2
      minimumInputLength: 1
      multiple: true
      tags: true
      tokenSeparators: [',', ' ']
      placeholder:  "Add a tag"
      initSelection: (element, callback) ->
        data = { text: element.data("tag-name") }
        callback(data)

      createSearchChoice: (term, data) ->
          { id: term, text: term }

      width: '98%'
      formatResult: (object, container) ->
        text = if object.name?
          object.name
        else
          object.text
      formatSelection:  (object, container) ->
        text = if object.name?
          object.name
        else
          object.text
      ajax:
        url: '/tags/select.json'
        dataType: 'json'
        data: (term, page) ->
          q: term
        results: (data, page) ->
          results: data

updatePasswords = (checked) ->
  $('#space_bigbluebutton_room_attributes_attendee_key').prop('disabled', checked)
  $('#space_bigbluebutton_room_attributes_moderator_key').prop('disabled', checked)
