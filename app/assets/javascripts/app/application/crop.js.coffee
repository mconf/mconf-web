# To make a form to select an image to be cropped, point the form
# to a "precrop" action and add :class => 'form-for-crop' to it.
# The form must have a input[type=file] in it and optionally a link
# with :"data-open-file" => true to trigger the "browse files" window.

saveCropCoordinates = (crop) ->
  # TODO: restrict the search to the elements inside the form
  # where this event was triggered
  $('#crop_x').val(crop.x)
  $('#crop_y').val(crop.y)
  $('#crop_w').val(crop.w)
  $('#crop_h').val(crop.h)

# Enables the crop in all 'cropable' elements in the document
enableCropInImages = ->
  # TODO: set min, max and an initial area selected
  $("img.cropable").each ->
    $(this).Jcrop
      aspectRatio: 1
      setSelect: [0, 0, 350, 350]
      onSelect: update
      onChange: update

update = (coords) =>
  $('#crop_x').val(coords.x)
  $('#crop_y').val(coords.y)
  $('#crop_w').val(coords.w)
  $('#crop_h').val(coords.h)
  updatePreview(coords)

updatePreview = (coords) =>
  $('#preview').css
    width: Math.round(100/coords.w * $('#cropbox').width()) + 'px'
    height: Math.round(100/coords.h * $('#cropbox').height()) + 'px'
    marginLeft: '-' + Math.round(100/coords.w * coords.x) + 'px'
    marginTop: '-' + Math.round(100/coords.h * coords.y) + 'px'

# Makes the crop form be submitted with ajax
bindAjaxToCropForm = ->
  $('#crop-form').ajaxForm
    success: (data) ->
      $(document).trigger "crop-form-success", data
      mconf.Modal.closeWindows();
    error: () ->
      $(document).trigger "crop-form-error"

# All forms with '.form-for-crop' will be associated with the crop
# functionality. The contents returned after the form is submitted are
# shown in a modal window and the image in it can be cropped.
enableAjaxInCropForms = ->
  $("form.form-for-crop").each ->
    form = $(this)
    # when the user selects a file it automatically submits the form
    $element = $("input[type=file]", form)
    $element.on "change", ->
      form.ajaxSubmit (data) ->
        mconf.Modal.showWindow
          data: data
          element: $element
        enableCropInImages()
        bindAjaxToCropForm()

# Triggers the associations...
$ ->
  enableAjaxInCropForms()
