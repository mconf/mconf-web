$ ->
  if isOnPage 'spaces', 'edit'
    updatePasswords($('input#space_public').is(':checked'))
    $('input#space_public').on 'click', -> updatePasswords($(this).is(':checked'))

    uploaderCallbacks =
      onComplete: mconf.Crop.onUploadComplete

    mconf.Uploader.bind
      callbacks: uploaderCallbacks

    tag_list_id = "#space_tag_list"

    #select values already tagged
    $(tag_list_id).ready ->
      values = []

      for value in $(tag_list_id).val().split(',')
        values.push {id: value, text: value} if value != ''

      $(tag_list_id).select2 'data', values
      $(tag_list_id).show()

    # select input to search for spaces
    $(tag_list_id).select2
      minimumInputLength: 1
      multiple: true
      tags: true
      tokenSeparators: [',', ';']
      placeholder:  "Add a tag"

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
          results: data.map (term) -> { id: term.name, text: term.name }

updatePasswords = (checked) ->
  $('#space_bigbluebutton_room_attributes_attendee_key').prop('disabled', checked)
  $('#space_bigbluebutton_room_attributes_moderator_key').prop('disabled', checked)
