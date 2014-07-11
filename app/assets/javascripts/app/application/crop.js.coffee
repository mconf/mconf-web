# This class binds JCrop to img.cropbable elements. It uses the elements
# with class .crop-x, .crop-y, .crop-w and .crop-h to store the user choice and adjusts the image with
# class .crop-preview to act as a preview
class mconf.Crop

  # Enables the crop in all 'cropable' elements in the document
  @bind: ->
    $("img.cropable").each ->
      image = this
      $(image).Jcrop
        aspectRatio: $(image).attr('data-crop-aspect-ratio')
        setSelect: [0, 0, 350, 350]
        onSelect: (coords) -> update(image, coords)
        onChange: (coords) -> update(image, coords)

# Updates the attributes in the page using the coordinates set by Jcrop.
# `image` is the image that's being cropped and `coords` the coordinates set by Jcrop over
# this image.
update = (image, coords) ->
  $('.crop-x').val(coords.x)
  $('.crop-y').val(coords.y)
  $('.crop-w').val(coords.w)
  $('.crop-h').val(coords.h)
  updatePreview(image, coords)

updatePreview = (image, coords) ->
  cropWidth = $(image).attr("data-crop-width")
  $('.crop-preview').css
    width: Math.round(cropWidth/coords.w * $(image).width()) + 'px'
    height: Math.round(100/coords.h * $(image).height()) + 'px'
    marginLeft: '-' + Math.round(cropWidth/coords.w * coords.x) + 'px'
    marginTop: '-' + Math.round(100/coords.h * coords.y) + 'px'
