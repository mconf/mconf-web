$ ->
  if isOnPage 'join_requests', 'invite'

    id = '#candidates'
    url = '/users/select'

    $(id).select2
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
