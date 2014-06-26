  $ ->
    if isOnPage 'sites', 'edit'
      $("#site_timezone").select2
        minimumInputLength: 0
        width: '100%'
