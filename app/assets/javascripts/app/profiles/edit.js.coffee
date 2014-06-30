$ ->
  if isOnPage 'profiles', 'edit'

    uploader_callbacks =
      onComplete: (id, name, response) ->
        if response.success
          $.get response.redirect_url, (data) ->
            # show the modal
            mconf.Modal.showWindow
              data: data
            mconf.Crop.bindCrop()

    mconf.Uploader.bindAll(uploader_callbacks)
