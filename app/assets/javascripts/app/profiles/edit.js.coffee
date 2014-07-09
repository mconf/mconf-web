$ ->
  if isOnPage 'profiles', 'edit'

    uploaderCallbacks =
      onComplete: (id, name, response) ->
        if response.success
          $.get response.redirect_url, (data) ->
            # show the modal
            mconf.Modal.showWindow
              data: data
            mconf.Crop.bindCrop()

    mconf.Uploader.bind
      callbacks: uploaderCallbacks
