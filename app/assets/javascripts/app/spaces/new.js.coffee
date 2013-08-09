$ ->

  $("#new-space-basic-info input#space_public").on 'click', ->
    $("#new-space-webconf-area").toggle(! $(this).is(':checked'))
