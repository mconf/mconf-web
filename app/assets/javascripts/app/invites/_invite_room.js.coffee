idMembers = '#invite_members_tokens'
idEmails = '#invite_email_tokens'
url = '/users/select'

mconf.Invites or= {}

class mconf.Invites.InviteRoom

  @bind: ->
    bindMembers()
    bindEmails()

  @unbind: ->
    # TODO: can it be done?

bindMembers = ->
  $(idMembers).select2
    minimumInputLength: 1
    width: 'resolve'
    multiple: true
    formatSearching: () -> I18n.t('invite_people.users.searching')
    formatInputTooShort: () -> I18n.t('invite_people.users.hint')
    tags: true
    tokenSeparators: [",",";"]
    ajax:
      url: url
      dataType: "json"
      data: (term, page) ->
        q: term # search term
      results: (data, page) -> # parse the results into the format expected by Select2.
        results: data

bindEmails = ->
  $(idEmails).select2
    minimumInputLength: 1
    placeholder: I18n.t('invite_people.email.other')
    width: 'resolve'
    multiple: true
    tags: true
    tokenSeparators: [",",";"," "]
