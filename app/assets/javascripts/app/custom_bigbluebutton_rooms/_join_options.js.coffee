mconf.CustomBigbluebuttonRooms or= {}

class mconf.CustomBigbluebuttonRooms.JoinOptions
  @setup: ->
    $(document).on "change", "#webconference-join-options-dialog #bigbluebutton_room_record", ->
      mconf.CustomBigbluebuttonRooms.JoinOptions.verifyInputs()

  # disable some options if the record checkbox is not checked
  @verifyInputs: ->
    $record = $("#webconference-join-options-dialog #bigbluebutton_room_record")
    $("#webconference-join-options-dialog input[type=text]").prop("disabled", !$record.is(":checked"))
