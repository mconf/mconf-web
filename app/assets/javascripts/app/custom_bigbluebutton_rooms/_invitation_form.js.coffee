idUsers = '#invite_users'
idEmails = '#invite_email_tokens'
url = '/users/select'

mconf.CustomBigbluebuttonRooms or= {}

class mconf.CustomBigbluebuttonRooms.Invitation

  @bind: ->
    bindUsers()

  @unbind: ->
    # TODO: can it be done?

bindUsers = ->
  $(idUsers).select2
    minimumInputLength: 1
    width: 'resolve'
    multiple: true
    formatSearching: -> I18n.t('invite_people.users.searching')
    formatInputTooShort: -> I18n.t('invite_people.users.hint')
    tags: true
    tokenSeparators: [",", ";"]
    createSearchChoice: (term, data) ->
      if mconf.Base.validateEmail(term)
        { id: term, text: term }
    ajax:
      url: url
      dataType: "json"
      data: (term, page) ->
        q: term # search term
      results: (data, page) -> # parse the results into the format expected by Select2.
        results: data
