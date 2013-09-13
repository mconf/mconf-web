$ ->

  $("#edit-space-basic-info input#space_public").on 'click', ->
    $("#edit-space-webconf-area").toggle(! $(this).is(':checked'))
    $("#space_bigbluebutton_room_attributes_attendee_password").prop("disabled", $(this).is(':checked'))
    $("#space_bigbluebutton_room_attributes_moderator_password").prop("disabled", $(this).is(':checked'))