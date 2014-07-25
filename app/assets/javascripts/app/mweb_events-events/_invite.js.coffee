usersSelector = '#invite_users'
searchUsersUrl = '/users/select?limit=7'

mconf.MwebEventsEvents or= {}

class mconf.MwebEventsEvents.Invitation

  @bind: ->
    bindUsers()

  @unbind: ->
    # TODO: can it be done?

bindUsers = ->
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
        { id: term, text: term }
    formatSelection: (object, container) ->
      if object.name?
        object.name
      else
        object.text
    ajax:
      url: searchUsersUrl
      dataType: "json"
      data: (term, page) ->
        q: term # search term
      results: (data, page) -> # parse the results into the format expected by Select2.
        results: data

mconf.MwebEventsEvents.Invitation.bind()
