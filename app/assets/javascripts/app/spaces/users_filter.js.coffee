$ ->
  speed = "slow"

  clear_users = ->
    $("#unselected_users .user_checkbox").hide()
    $("#show_all_users_link").show()

  show_all_users = ->
    $(".user_checkbox").show speed
    $("#show_all_users_link").hide()
    $("#hide_all_users_link").show()

  hide_all_users = ->
    $("#unselected_users .user_checkbox").hide speed
    $("#hide_all_users_link").hide()
    $("#show_all_users_link").show()

  select_all_users = ->
    $("#unselected_users .user_checkbox input").each ->
      $(this).attr "checked", true
      $(this).allocate()

    $("#show_all_users_link").hide()
    $("#hide_all_users_link").hide()
    $("#select_all_users_link").hide()
    $("#deselect_all_users_link").show()
    $("#selected_users label:first").show()

  deselect_all_users = ->
    $("#selected_users .user_checkbox input").each ->
      $(this).attr "checked", false
      $(this).allocate()

    $("#unselected_users .user_checkbox").hide speed
    $("#show_all_users_link").show()
    $("#select_all_users_link").show()
    $("#deselect_all_users_link").hide()
    $("#selected_users label:first").hide()

  selected_users_check = ->
    if $(".user_checkbox input:checked").length > 0
      $("#selected_users label:first").show()
    else
      $("#selected_users label:first").hide()

  filter_user = (filter_text) ->
    $("#unselected_users .user_checkbox").each ->
      if $(this).find("label").text().toLowerCase().search(filter_text) >= 0
        $(this).show speed
      else
        $(this).hide speed

    $(".user_checkbox input:checked").each ->
      $(this).parent().show()


  $.extend $.fn,
    allocate: ->
      if $(this).is(":checked")
        if $(this).parents("#selected_users").length is 0
          cb = $(this).parent().clone().hide()
          $("#selected_users").append cb
          $(this).parent().hide speed, ->
            $(this).remove()

          cb.show speed
      else
        if $(this).parents("#unselected_users").length is 0
          cb = $(this).parent().clone().hide()
          $("#unselected_users").append cb
          $(this).parent().hide speed, ->
            $(this).remove()

          cb.show speed

  $ ->
    $("#user_filter").show()
    selected_users_check()
    $(".user_checkbox input").each ->
      $(this).allocate()

    $("#hide_all_users_link").hide()
    $("#deselect_all_users_link").hide()
    clear_users()

  $(".user_checkbox input").livequery "click", ->
    selected_users_check()
    $(this).allocate()

  $("#user_selector").livequery "keyup", ->
    if @value is ""
      clear_users()
    else
      filter_text = @value.toLowerCase()
      filter_user filter_text
      $("#show_all_users_link").hide()
