$(document).ready ->

  #Add and rm tags functions
  $("#tag_filter").show()
  hide_table = ->
    $("#doc_repository").parent().html I18n.t("repository.loading")

  tags_array = ->
    $.map $("#attachment_tags_filter option.selected"), (element) ->
      element.value

  update_tags = (tags) ->
    unless $.deparam.querystring().tags is tags.join(",")
      hide_table()
      window.location = $.param.querystring(window.location + "", "tags=" + tags.join(","))

  add_tag = ->
    tags = tags_array()
    update_tags tags

  rm_tag = (item) ->
    tags = tags_array()
    i = 0

    while i < tags.length
      if tags[i] is item._value
        tags.splice i, 1
        break
      i++
    update_tags tags

  $("#attachment_tags_filter").fcbkcomplete
    cache: true
    filter_case: false
    filter_hide: true
    firstselected: true
    filter_selected: true
    maxshownitems: 4
    newel: false
    complete_opts: true
    onremove: rm_tag
    onselect: add_tag

  $(".add_tag_filter").click ->
    hide_table()

  #Tag list functions
  collapse_tag_list = ->
    $("#tag_abc_list").hide()
    $("#tag_used_list").hide()
    $("#tag_collapsed_list").show()

  used_tag_list = ->
    $("#tag_abc_list").hide()
    $("#tag_used_list").show()
    $("#tag_collapsed_list").hide()

  abc_tag_list = ->
    $("#tag_abc_list").show()
    $("#tag_used_list").hide()
    $("#tag_collapsed_list").hide()

  $("a.tag_list_abc_order").click ->
    abc_tag_list()
    false

  $("a.tag_list_used_order").click ->
    used_tag_list()
    false
