usersSelector = '#invite_users'
searchUsersUrl = '/users/select?limit=7'
titleSelector = '#invite_title'
buttonSelector = '#event-invitation input.btn[type=\'submit\']'

mconf.MwebEventsEvents or= {}

class mconf.MwebEventsEvents.Invitation

  @bind: ->
    invitation = new mconf.MwebEventsEvents.Invitation()
    invitation.checkRequired()
    invitation.bindUsers()
    invitation.bindTitle()

  @unbind: ->
    # TODO: can it be done?

  # Dont enable the form button unless user has filled in users and title
  checkRequired: ->
    if $(titleSelector).first().val().length > 0 and $(usersSelector).val().length
      $(buttonSelector).removeAttr('disabled')
    else
      $(buttonSelector).attr('disabled','disabled')

  bindTitle: ->
    $(titleSelector).on "keydown keyup", =>
      @checkRequired()

  bindUsers: ->
    $(usersSelector).select2
      minimumInputLength: 1
      width: 'resolve'
      multiple: true
      formatSearching: -> I18n.t('custom_bigbluebutton_rooms.invitation_form.users.searching')
      formatInputTooShort: -> I18n.t('custom_bigbluebutton_rooms.invitation_form.users.hint')
      formatNoMatches: -> I18n.t('custom_bigbluebutton_rooms.invitation_form.users.no_results')
      tags: true
      tokenSeparators: [",", ";"]
      createSearchChoice: (term, data) ->
        if mconf.Base.validateEmail(term)
          { id: term, text: mconf.Base.escapeHTML(term) }
      formatSelection: (object, container) ->
        text = if object.name?
          object.name
        else
          object.text

        mconf.Base.escapeHTML(text)
      ajax:
        url: searchUsersUrl
        dataType: "json"
        data: (term, page) ->
          q: term # search term
        results: (data, page) -> # parse the results into the format expected by Select2.
          results: data

    $(usersSelector).on "change", =>
      @checkRequired()

mconf.MwebEventsEvents.Invitation.bind()
