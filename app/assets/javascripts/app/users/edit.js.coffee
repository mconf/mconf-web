$ ->
  if isOnPage 'users', 'edit|update'
    $("#user_timezone").select2
      minimumInputLength: 0
      width: '100%'
