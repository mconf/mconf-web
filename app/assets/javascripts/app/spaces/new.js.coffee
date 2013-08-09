$ ->

  $("#new-space-basic-info input#space_public").on 'click', ->
    checked = $(this).attr('checked') == 'checked'
    $("#new-space-webconf-area").toggle(!checked)
