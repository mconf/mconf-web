#= require "../custom_bigbluebutton_rooms/_invitation_form"

mconf.Spaces or= {}

class mconf.Spaces.Sidebar

  @bind: ->
    @unbind()

    mconf.Resources.addToBind ->
      mconf.CustomBigbluebuttonRooms.Invitation.bind()

    $("#webconference-share .open-modal").on "modal-hidden.mconfSpacesWebconference", ->
      mconf.CustomBigbluebuttonRooms.Invitation.unbind()

  @unbind: ->
    $(document).off "modal-shown.mconfSpacesWebconference"
    $("#webconference-share .open-modal").off "modal-hidden.mconfSpacesWebconference"
