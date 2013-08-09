$(document).ready ->

  $("#manage_space_filter input#enabled").on 'click', ->
    $("div.enabled").toggle($(this).is(':checked'))

  $("#manage_space_filter input#disabled").on 'click', ->
    $("div.disabled").toggle($(this).is(':checked'))