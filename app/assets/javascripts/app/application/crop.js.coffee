# To make a form to select an image to be cropped, point the form
# to a "precrop" action and add :class => 'form-for-crop' to it.
# The form must have a input[type=file] in it and optionally a link
# with :"data-open-file" => true to trigger the "browse files" window.

class mconf.Crop

  # All forms with '.form-for-crop' will be associated with the crop
  # functionality. The contents returned after the form is submitted are
  # shown in a modal window and the image in it can be cropped.
  @bind: ->
    $("form.form-for-crop").each ->
      form = $(this)
      # when the user selects a file it automatically submits the form
      $element = $("input[type=file]", form)
      $element.off "change.mconfCrop"
      $element.on "change.mconfCrop", ->
        form.ajaxSubmit (data) ->
          mconf.Modal.showWindow
            data: data
            element: $element
          enableCropInImages()
          bindAjaxToCropForm()

$ ->
  mconf.Crop.bind()


saveCropCoordinates = (crop) ->
  # TODO: restrict the search to the elements inside the form
  # where this event was triggered
  $('#crop_x').val(crop.x)
  $('#crop_y').val(crop.y)
  $('#crop_w').val(crop.w)
  $('#crop_h').val(crop.h)

# Enables the crop in all 'cropable' elements in the document
enableCropInImages = ->
  $("img.cropable").each ->
    $(this).Jcrop
      aspectRatio: $("#aspect_ratio").text()
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
    width: Math.round($("#width").text()/coords.w * $('#cropbox').width()) + 'px'
    height: Math.round(100/coords.h * $('#cropbox').height()) + 'px'
    marginLeft: '-' + Math.round($("#width").text()/coords.w * coords.x) + 'px'
    marginTop: '-' + Math.round(100/coords.h * coords.y) + 'px'

# Makes the crop form be submitted with ajax
bindAjaxToCropForm = ->
  $('#crop-form').ajaxForm
    success: (data) ->
      $(document).trigger "crop-form-success", data
      mconf.Modal.closeWindows();
      $('#logo_image').empty()
      $('#logo_image').html($(data).find('#logo_image').find("img"))
      $('#notification-flashs').html('<div name="success" data-notification-shown="0">' + I18n.t('logo.created') + '</div>')
      $("form.form-for-crop").resetForm()
      mconf.Notification.bind()
    error: () ->
      $(document).trigger "crop-form-error"
      $('#notification-flashs').html('<div name="error" data-notification-shown="0">' + I18n.t('logo.error') + '</div>')
      $("form.form-for-crop").resetForm()
      mconf.Notification.bind()
