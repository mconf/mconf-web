mconf.CustomBigbluebuttonRooms or= {}

class mconf.CustomBigbluebuttonRooms.JoinOptions

  @bind: ->
    @unbind()

    # when the checkbox is changed the inputs have to be disabled/enabled
    $("#webconference-join-options-dialog #bigbluebutton_room_record").on "change.mconfJoinOptions", ->
      mconf.CustomBigbluebuttonRooms.JoinOptions.verifyInputs()

    # TODO: not the best option to find the button, but can't add an id to it because
    #       the lib modal2 moves the button to the modal footer and removes the id
    $goButton = $(".modal .modal-footer .btn")

    # disable/enable the "start the meeting" button when ajax request are in process
    $("#webconference-join-options-dialog input.in-place-edit").on "in-place-edit-submitting.mconfJoinOptions", ->
      $goButton.addClass("disabled")
    $("#webconference-join-options-dialog input.in-place-edit").on "in-place-edit-success.mconfJoinOptions", ->
      $goButton.removeClass("disabled")
    $("#webconference-join-options-dialog input.in-place-edit").on "in-place-edit-error.mconfJoinOptions", ->
      $goButton.removeClass("disabled")

  # unbind all the events we bind in this class
  @unbind: ->
    $("#webconference-join-options-dialog #bigbluebutton_room_record").off "change.mconfJoinOptions"
    $("#webconference-join-options-dialog input.in-place-edit").off "in-place-edit-submitting.mconfJoinOptions"
    $("#webconference-join-options-dialog input.in-place-edit").off "in-place-edit-success.mconfJoinOptions"
    $("#webconference-join-options-dialog input.in-place-edit").off "in-place-edit-error.mconfJoinOptions"

  # disable some options if the record checkbox is not checked
  @verifyInputs: ->
    $record = $("#webconference-join-options-dialog #bigbluebutton_room_record")
    checked = $record.is(":checked")
    $("#webconference-join-options-dialog input[type=text]").prop("disabled", !checked)
