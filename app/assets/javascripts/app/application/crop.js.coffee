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
        onSelect: (coords) ->
          update(image, coords)
          enableDisableSubmit($(image).attr('data-crop-button'), true)
        onChange: (coords) ->
          update(image, coords)
          enableDisableSubmit($(image).attr('data-crop-button'), true)
        onRelease: ->
          enableDisableSubmit($(image).attr('data-crop-button'), false)
          # select the entire image if the selection area is released
          # note: only happens when the aspect ratio is fixed, otherwise
          # it will never release the selection area
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

# Updates the attributes in the page using the coordinates set by Jcrop.
# `image` is the image that's being cropped and `coords` the coordinates set by Jcrop over
# this image.
update = (image, coords) ->
  $('.crop-x').val(coords.x)
  $('.crop-y').val(coords.y)
  $('.crop-w').val(coords.w)
  $('.crop-h').val(coords.h)

enableDisableSubmit = (id, enable) ->
  if enable
    $("##{id}").removeClass('disabled')
    $("##{id}").attr('disabled', null)
  else
    $("##{id}").addClass('disabled')
    $("##{id}").attr('disabled', 'disabled')
