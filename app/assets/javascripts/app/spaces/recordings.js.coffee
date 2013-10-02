# What is done here is almost duplicated at my/room_recordings.js.coffee
# The ids are slightly different, so we didn't make this a partial. But whatever is
# done here might have to be done at my/room_recordings.js.coffee as well.

$ ->
  if isOnPage 'spaces', 'recordings'

    # make a request to fetch the recordings from the webconf server and update
    # the internal db
    $form = $('#space-recordings-fetch')
    $form.on "ajax:success", (evt, data, status, xhr) ->
      submitFormUpdate()
    $form.on "ajax:error", (evt, xhr, status) ->
      showErrorNotification(xhr)
      showStatus('error')
    showStatus('loading')
    $form.submit()

# Submits a form to request an updated list of recordings, and uses the response
# to replace the html in the page.
submitFormUpdate = ->
  $form = $('#space-recordings-update')
  $form.on "ajax:success", (evt, data, status, xhr) ->
    $('#space-recordings-list-wrapper').html(data)
    mconf.Resources.bind() # for the new content added
    showStatus('success')
  $form.on "ajax:error", (evt, xhr, status) ->
    showErrorNotification(xhr)
    showStatus('error')
  $form.submit()

# Shows the target status message and hides all the others.
showStatus = (status) ->
  $('#space-recordings-fetch').children().hide()
  $("#space-recordings-#{status}").show()
  window.setTimeout ->
    $("#space-recordings-#{status}").hide()
  , 10000

# Show a notification with the error that occurred in the request `xhr`.
showErrorNotification = (xhr) ->
  if xhr?.responseText? and !_.isEmpty(xhr.responseText.trim())
    response = JSON.parse(xhr.responseText)
    if response?.message?
      # for now just print it in the console
      msg = I18n.t("my.room_recordings.update_recordings.error") + ': ' + response.message
      console.log msg
      # TODO: we could show a real notification to the user, but not sure this is the kind of
      #   error the user should see
      # mconf.Notification.add("error", msg)
      # mconf.Notification.bind()
