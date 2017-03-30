#= require "../custom_bigbluebutton_rooms/_invitation_form"
#= require "../custom_bigbluebutton_rooms/user_edit"

mconf.Spaces or= {}

# Javascript for the sidebar show in all spaces, in several pages.
# Almost the same that is done in my/home
class mconf.Spaces.Sidebar

  @bind: ->
    @unbind()

    # set to rebind thing when the resources are rebound
    mconf.Resources.addToBind ->
      mconf.CustomBigbluebuttonRooms.Invitation.bind()
      mconf.UserEdit.setup()
    # this modal binds some things in the modal using "global" selectors such as ".modal"
    # so we make sure we unbind everything when the modal is closed
    $("#sidebar-webconference .webconf-join-group .open-modal").on "modal-hidden.mconfSpacesSidebar", ->
      mconf.CustomBigbluebuttonRooms.Invitation.unbind()

  @unbind: ->
    $(document).off "modal-shown.mconfSpacesSidebar"
    $("#sidebar-webconference .webconf-join-group .open-modal").off "modal-hidden.mconfSpacesSidebar"
