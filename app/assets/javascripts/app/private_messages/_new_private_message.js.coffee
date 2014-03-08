$ ->
  if isOnPage 'private_messages', 'new|create'

    $('#private_message_users_tokens').select2
      minimumInputLength: 1
      width: 'resolve'
      multiple: true
      formatSearching: -> I18n.t('private_messages.new.users.searching')
      formatInputTooShort: -> I18n.t('private_messages.new.users.hint')
      formatNoMatches: -> I18n.t('private_messages.new.users.no_results')
      tags: true
      tokenSeparators: [",",";"]
      initSelection: (element, callback) ->
        params = { dataType: "json" }
        $.ajax("/users/select?i=#{element.val()}", params).done (data) ->
          callback(data)
      formatSelection: (object, container) ->
        if object.name?
          object.name
        else
          object.text
      ajax:
        url: '/users/fellows.json?limit=10'
        dataType: "json"
        data: (term, page) ->
          q: term # search term
        results: (data, page) -> # parse the results into the format expected by Select2.
          results: data
