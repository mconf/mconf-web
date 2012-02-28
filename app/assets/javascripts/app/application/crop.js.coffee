# Enables the crop in all 'cropable' elements
setCropToElements = ->
  # TODO: set min, max and an initial area selected
  $("img.cropable").each ->
    $(this).Jcrop
      onSelect: saveCropCoordinates,
      onChange: saveCropCoordinates,
      aspectRatio: parseInt($(this).attr("data-crop-aspect-ratio"))

saveCropCoordinates = (crop) ->
  # TODO: restrict the search to the elements inside the form
  # where this event was triggered
  $("input#crop_size_x").val crop.x
  $("input#crop_size_y").val crop.y
  $("input#crop_size_height").val crop.h
  $("input#crop_size_width").val crop.w


# Associates the form #id with a precrop action
# The contents returned after the form is submitted are shown
# in a modal window and the image in it can be cropped.
window.mconfPrecropImage = (id) ->
  form = $("#" + id)
  form.ajaxForm (data) ->
    showModalWindow(data)
    setCropToElements()

$ ->
  setCropToElements()