$ ->
  if isOnPage 'users', 'edit'
    $("#user_timezone").select2
      minimumInputLength: 0
      width: '100%'
