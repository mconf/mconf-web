$ ->
  if isOnPage 'private_messages', 'new|create'
    $("#private_message_users_tokens").tokenInput "/users/fellows.json",  
      {
        crossDomain: false,
        theme: 'facebook',
        preventDuplicates: true,
        searchDelay: 150
      };

