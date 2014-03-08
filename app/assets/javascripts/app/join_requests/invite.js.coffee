$ ->
  if isOnPage 'join_requests', 'invite'

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
        if object.name?
          object.name
        else
          object.text
      ajax:
        url: url
        dataType: "json"
        data: (term, page) ->
          q: term # search term
        results: (data, page) -> # parse the results into the format expected by Select2.
          results: data
