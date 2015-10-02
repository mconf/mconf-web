$ ->
  if isOnPage 'attachments', 'index'

    # selecting/deselecting an attachment
    $(".attachment-checkbox").on "click", ->
      updateAll()

    # initialize all
    updateAll()

    # bind uploader
    uploaderCallbacks =
      onComplete: (id, name, response) ->
        if response.success
          $.get response.redirect_url, (data) ->
            window.setTimeout ->
              $('.file-uploader').hide()
              mconf.Modal.closeWindows()
            , 1000
            window.setTimeout ->
              window.location.assign(response.redirect_url)
            , 1500

      onSubmit: (id, name) ->
        $('.upload-button').hide()

    $("#new-file").on "modal-shown", ->
      mconf.Uploader.bind
        dragAndDrop: true
        callbacks: uploaderCallbacks

updateAll = ->
  updateDeleteLink()
  updateDownloadLink()
  updateSelectedLabel()

# Update the link and state of the "delete multiple" button depending on the files that
# are selected (if any).
updateDeleteLink = ->
  $button = $("#attachments-delete")
  attachments = getSelectedAttachments()
  if attachments.length > 0 and canDeleteSelected()
    baseUrl = $button.data("base-url")
    $button.attr "href", "#{baseUrl}?attachment_ids=#{attachments.join(",")}"
    $button.attr "data-method", "delete"
    $button.attr "disabled", null
    $button.removeClass "disabled"
  else
    $button.attr "href", "#"
    $button.attr "data-method", null
    $button.attr "disabled", "disabled"
    $button.addClass "disabled"

# Update the link and state of the "download multiple" button depending on the files that
# are selected (if any).
updateDownloadLink = ->
  $button = $("#attachments-download")
  attachments = getSelectedAttachments()
  if attachments.length > 0
    baseUrl = $button.data("base-url")
    $button.attr "href", "#{baseUrl}.zip?attachment_ids=#{attachments.join(",")}"
    $button.attr "disabled", null
    $button.removeClass "disabled"
  else
    $button.attr "href", "#"
    $button.attr "disabled", "disabled"
    $button.addClass "disabled"

# Updates the text informing how many files are selected
updateSelectedLabel = ->
  attachments = getSelectedAttachments()
  if attachments.length is 0
    $("#space-attachments-selected").html I18n.t("attachment.selected.none")
  else
    if attachments.length is 1
      $("#space-attachments-selected").html "#{attachments.length} #{I18n.t("attachment.selected.one")}"
    else
      $("#space-attachments-selected").html "#{attachments.length} #{I18n.t("attachment.selected.other")}"

# Returns an array with the value of all selected attachments
getSelectedAttachments = ->
  sa = new Array()
  $(".attachment-checkbox:checked").each ->
    sa.push $(this).attr("value")
  sa

# returns whether the user can delete all attachments currently selected
canDeleteSelected = ->
  can = true
  $(".attachment-checkbox:checked").each ->
    can = false unless $(this).data("can-destroy")
  can
