$ ->

  $("#edit-space-basic-info input#space_public").on 'click', ->
    $("#edit-space-webconf-area").toggle(! $(this).is(':checked'))