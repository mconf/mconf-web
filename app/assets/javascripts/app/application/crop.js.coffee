# This class binds JCrop to img.cropbable elements. It uses the elements
# with class .crop-x, .crop-y, .crop-w and .crop-h to store the user choice and adjusts the image with
# class .crop-preview to act as a preview
class mconf.Crop

  # Custom selection class.
  # Taken from Jcrop's demos.
  CircleSel = ->
  CircleSel.prototype = new ($.Jcrop.component.Selection)
  $.extend CircleSel.prototype,
    zoomscale: 1
    # attach: ->
    #   @frame.css background: 'url(' + $('img.cropable')[0].src.replace('750', '750') + ')'
    #   return
    positionBg: (b) ->
      midx = (b.x + b.x2) / 2
      midy = (b.y + b.y2) / 2
      ox = -midx * @zoomscale + b.w / 2
      oy = -midy * @zoomscale + b.h / 2
      #this.frame.css({ backgroundPosition: ox+'px '+oy+'px' });
      @frame.css backgroundPosition: -(b.x + 1) + 'px ' + -b.y - 1 + 'px'
      return
    redraw: (b) ->
      # Call original update() method first, with arguments
      $.Jcrop.component.Selection::redraw.call this, b
      @positionBg @last
      this
    prototype: $.Jcrop.component.Selection.prototype


  # Enables the crop in all 'cropable' elements in the document
  @bind: ->
    $("img.cropable").each ->
      image = this

      options =
        bgColor: 'black'
        aspectRatio: $(image).data('crop-aspect-ratio')
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

      if $(image).data('crop-circular') is true
        circularOptions =
          selectionComponent: CircleSel
          handles: [ 'n','s','e','w' ]
          applyFilters: [ 'constrain', 'extent', 'backoff', 'ratio', 'round' ]
          dragbars: [ ]
          borders: [ ]
          aspectRatio: 1
        _.extend(options, circularOptions)

      $(image).Jcrop(options)

      $('[data-crop="aspect-ratio-input"]').on "change", ->
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
