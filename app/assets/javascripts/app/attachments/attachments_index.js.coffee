$(document).ready ->

  #Upload form
  # hide_table = ->
  #   $("#doc_repository").parent().html()
  #   teste = I18n.t("repository.loading")

  # $("input#add_post").livequery "click", ->
  #   $("#with_post").slideToggle()

  # $("#upload_field").livequery "change", ->
  #   $("#button_submit").show()

  # $("#add_document_label_link").click ->
  #   $("#new_attachment").effect "highlight",
  #     color: "#F5DF51"
  #   , 3000

  # # Action links
  # $("a.repository_sidebar_action").livequery "click", ->
  #   if $(this).hasClass("disabled_button")
  #     false
  #   else
  #     collapse_tag_list()
  #     $.getScript @href
  #     false

  #Multiple selectors actions
  # selected_attachments = ->
  #   sa = new Array()
  #   $(".attachment_checkbox").each ->
  #     sa.push $(this).attr("value")  if $(this).attr("checked")

  #   sa

  # can_delete_selected = ->
  #   can_delete = true
  #   $(".attachment_checkbox:checked").each ->
  #     can_delete = false  unless $(this).parents("tr.attachment").hasClass("can_delete")

  #   can_delete

  # update_selected = ->
  #   sa = selected_attachments()
  #   if sa.length is 0
  #     $("#selected_info").html I18n.t("attachment.selected.none")
  #     $("#multiple_download").addClass "disabled_button"
  #     $("#multiple_delete").addClass "disabled_button"
  #   else
  #     if sa.length is 1
  #       $("#selected_info").html sa.length + " " + I18n.t("attachment.selected.one")
  #     else
  #       $("#selected_info").html sa.length + " " + I18n.t("attachment.selected.other")
  #     $("#multiple_download").removeClass "disabled_button"

  #     #Check permissions
  #     if can_delete_selected()
  #       $("#multiple_delete").removeClass "disabled_button"
  #     else
  #       $("#multiple_delete").addClass "disabled_button"

  # $(".attachment_checkbox").click ->
  #   update_selected()

  # $("#select_all_checkbox").click ->
  #   if $(this).attr("checked")
  #     $(".attachment_checkbox").attr "checked", true
  #   else
  #     $(".attachment_checkbox").attr "checked", false
  #   update_selected()

  # $("#multiple_download").click ->
  #   if $(this).hasClass("disabled_button")
  #     false
  #   else
  #     sa = selected_attachments()
  #     $(this).attr "href", gon.attachments_path + ".zip/" + "?attachment_ids=" + sa.join(",")

  # $("#multiple_delete").click ->
  #   if $(this).hasClass("disabled_button")
  #     false
  #   else
  #     if confirm("Delete selected attachments?")
  #       sa = selected_attachments()
  #       f = document.createElement("form")
  #       f.style.display = "none"
  #       @parentNode.appendChild f
  #       f.method = "POST"
  #       f.action = gon.attachments_path + "?attachment_ids=" + sa.join(",")
  #       m = document.createElement("input")
  #       m.setAttribute "type", "hidden"
  #       m.setAttribute "name", "_method"
  #       m.setAttribute "value", "delete"
  #       f.appendChild m
  #       s = document.createElement("input")
  #       s.setAttribute "type", "hidden"
  #       s.setAttribute "name", "authenticity_token"
  #       s.setAttribute "value", gon.form_auth_token
  #       f.appendChild s
  #       f.submit()
  #     false

  #Initial actions
  # $("#enable_javascript").hide()
  # update_selected()

