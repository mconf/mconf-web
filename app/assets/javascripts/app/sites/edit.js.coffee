#= require jquery/jquery.sticky

$ ->
  if isOnPage 'sites', 'edit'
    $("#site_timezone").select2
      minimumInputLength: 0
      width: '100%'

    # Setup the sticky menu and add some events
    $("#site-edit-nav").on 'sticky-init', ->
      $('#site-edit-nav-sticky-wrapper').addClass('right-column')

    $("#site-edit-nav").on 'sticky-end', ->
      $('#site-edit-nav-sticky-wrapper').addClass('right-column')

    $("#site-edit-nav").sticky(
      topSpacing: 20
      bottomSpacing: 250
      className: 'right-column'
      widthFromWrapper: true
    )

    # Jump to the section which the user clicked
    $('.section-selector').click ->
      $('html, body').animate
        scrollTop: $($(this).attr('href')).offset().top - 40
      , 700

    shib_warning_enabled = false
    $("#site_shib_principal_name_field").on 'input', ->
      if not shib_warning_enabled
        shib_warning_enabled = true
        $("#shib-principal-name-warning").show(100)
