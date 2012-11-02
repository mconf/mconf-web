# To make a form to select an image to be cropped, point the form
# to a "precrop" action and add :class => 'form-for-crop' to it.
# The form must have a input[type=file] in it and optionally a link
# with :"data-open-file" => true to trigger the "browse files" window.

saveCropCoordinates = (crop) ->
  # TODO: restrict the search to the elements inside the form
  # where this event was triggered
  $("input#crop_size_x").val crop.x
  $("input#crop_size_y").val crop.y
  $("input#crop_size_height").val crop.h
  $("input#crop_size_width").val crop.w

# Enables the crop in all 'cropable' elements in the document
enableCropInImages = ->
  # TODO: set min, max and an initial area selected
  $("img.cropable").each ->
    $(this).Jcrop
      onSelect: saveCropCoordinates,
      onChange: saveCropCoordinates,
      aspectRatio: parseFloat($(this).attr("data-crop-aspect-ratio"))

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
    $("input[type=file]", form).on "change", ->
      form.ajaxSubmit (data) ->
        mconf.Modal.showWindow({ html: data })
        enableCropInImages()
        bindAjaxToCropForm()

# Triggers the associations...
$ ->
  enableAjaxInCropForms()
  enableCropInImages()
