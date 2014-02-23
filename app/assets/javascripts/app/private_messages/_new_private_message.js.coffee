$ ->
  if isOnPage 'private_messages', 'new|create'

    $('#private_message_users_tokens').select2
      minimumInputLength: 1
      width: 'resolve'
      multiple: true
      formatSearching: () -> I18n.t('invite_people.users.searching')
      formatInputTooShort: () -> I18n.t('invite_people.users.hint')
      tags: true
      tokenSeparators: [",",";"]
      initSelection: (element, callback) ->
        params = { dataType: "json" }
        $.ajax("/users/select?i=#{element.val()}", params).done (data) ->
          callback(data)
      ajax:
        url: '/users/fellows.json'
        dataType: "json"
        data: (term, page) ->
          q: term # search term
        results: (data, page) -> # parse the results into the format expected by Select2.
          results: data
