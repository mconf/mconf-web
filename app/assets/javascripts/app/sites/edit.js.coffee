  $ ->
    if isOnPage 'sites', 'edit'
      $("#site_timezone").select2
        minimumInputLength: 0
        width: '100%'

      shib_warning_enabled = false
      $("#site_shib_principal_name_field").on 'input', ->
        if not shib_warning_enabled
          shib_warning_enabled = true
          $("#shib-principal-name-warning").show(100)
