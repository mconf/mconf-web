#= require "../custom_bigbluebutton_rooms/_join_options"

mconf.Spaces or= {}

# Javascript for the sidebar show in all spaces, in several pages.
# Almost the same that is done in my/home
class mconf.Spaces.Sidebar

  @bind: ->
    @unbind()

    # set to rebind JoinOptions when the resources are rebound
    mconf.Resources.addToBind ->
      mconf.CustomBigbluebuttonRooms.JoinOptions.bind()

    # check the inputs for the first time when the modal is opened
    $(document).on "modal-shown.mconfSpacesSidebar", ->
      mconf.CustomBigbluebuttonRooms.JoinOptions.verifyInputs()

    # this modal binds some things in the modal using "global" selectors such as ".modal"
    # so we make sure we unbind everything when the modal is closed
    $("#sidebar-webconference .webconf-join-group .open-modal").on "modal-hidden.mconfSpacesSidebar", ->
      mconf.CustomBigbluebuttonRooms.JoinOptions.unbind()

  @unbind: ->
    $(document).off "modal-shown.mconfSpacesSidebar"
    $("#sidebar-webconference .webconf-join-group .open-modal").off "modal-hidden.mconfSpacesSidebar"
