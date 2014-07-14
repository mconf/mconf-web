$ ->
  if isOnPage 'profiles', 'edit'

    uploaderCallbacks =
      onComplete: (id, name, response) ->
        if response.success
          $.get response.redirect_url, (data) ->
            # show the crop modal
            mconf.Modal.showWindow
              data: data

    mconf.Uploader.bind
      callbacks: uploaderCallbacks
