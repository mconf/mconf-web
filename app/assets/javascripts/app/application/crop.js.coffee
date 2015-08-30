# This class binds JCrop to img.cropbable elements. It uses the elements
# with class .crop-x, .crop-y, .crop-w and .crop-h to store the user choice and adjusts the image with
# class .crop-preview to act as a preview
class mconf.Crop

  # Enables the crop in all 'cropable' elements in the document
  @bind: ->
    $("img.cropable").each ->
      image = this
      $('img.cropable').Jcrop
        aspectRatio: $(image).attr('data-crop-aspect-ratio')
        setSelect: [0, 0, 350, 350]
        minSize: [100, 100]
        allowSelect: false
        onSelect: (coords) ->
          update(image, coords)
          enableDisableSubmit($(image).attr('data-crop-button'), true)
        onChange: (coords) ->
          update(image, coords)
          enableDisableSubmit($(image).attr('data-crop-button'), true)

        # this doesn't really happen with 'allowSelect' set to false, it's here
        # just for extra precaution
        onRelease: ->
          enableDisableSubmit($(image).attr('data-crop-button'), false)
          coords =
            x: 0
            y: 0
            w: $(image).width()
            h: $(image).height()
          update(image, coords)

      $('#aspect-ratio').on "change", ->
        mconf.Crop.enableAspectRatio $(this).is(':checked')

  @enableAspectRatio: (enabled) ->
    $('img.cropable').data('Jcrop').setOptions
      aspectRatio: if enabled then $('img.cropable').attr('data-crop-aspect-ratio') else 0

  @onUploadComplete: (id, name, response) ->
    if response.success
      # show the crop modal if image is not too small
      if !response.small_image

        mconf.Modal.showWindow
          target: response.redirect_url

        # hack to set the redirect if the user closes the modal
        $('.modal').ready ->
          $(this).on 'hide', ->
            location.reload(true)

      else
        # redirect if the image was small and no crop happened
        location.reload(true)


# Updates the attributes in the page using the coordinates set by Jcrop.
# `image` is the image that's being cropped and `coords` the coordinates set by Jcrop over
# this image.
update = (image, coords) ->
  width = $(image).width()
  height = $(image).height()
  $('.crop-x').val(coords.x / width)
  $('.crop-y').val(coords.y / height)
  $('.crop-w').val(coords.w / width)
  $('.crop-h').val(coords.h / height)
  $('.crop-img-w').val(width)
  $('.crop-img-h').val(height)

enableDisableSubmit = (id, enable) ->
  if enable
    $("##{id}").removeClass('disabled')
    $("##{id}").attr('disabled', null)
  else
    $("##{id}").addClass('disabled')
    $("##{id}").attr('disabled', 'disabled')
