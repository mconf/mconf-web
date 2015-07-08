$ ->
  if isOnPage 'join_requests', 'invite'

    # invite is selected by default
    enableDisableMessage()

    # enable/disable the message depending on the type selected
    $('.type-options input[type=radio]').on 'change', ->
      enableDisableMessage()

    # input to search for users
    id = '#candidates'
    url = '/users/select?limit=10'
    $(id).select2
      minimumInputLength: 1
      width: 'resolve'
      multiple: true
      formatSearching: -> I18n.t('join_requests.invite.users.searching')
      formatInputTooShort: -> I18n.t('join_requests.invite.users.hint')
      formatNoMatches: -> I18n.t('join_requests.invite.users.no_results')
      tags: true
      tokenSeparators: [",",";"]

      formatSelection: (object, container) ->
        text = if object.name?
          object.name
        else
          object.text
        mconf.Base.escapeHTML(text)

      ajax:
        url: url
        dataType: "json"
        data: (term, page) ->
          q: term # search term
        results: (data, page) -> # parse the results into the format expected by Select2.
          results: data

enableDisableMessage = ->
  typeInvite = $('#type_invite')
  $('#join_request_comment').enable(typeInvite.is(":checked"))
