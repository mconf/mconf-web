# Setups FineUploader on elements with the class .file-uploader

class mconf.Uploader

  @bindAll: (param_options) ->
    element = $('.file-uploader')

    # Add some behavior to the callbacks
    callbacks = param_options.callbacks or {}

    onComplete = callbacks.onComplete
    onSubmit = callbacks.onSubmit
    callbacks.onComplete = (id, name, response) ->
      if response.success
        # Hide progress bar on successs
        $(".progress .bar:hidden").parent().hide()

      onComplete?(id, name, response)

    callbacks.onSubmit = (id, name) ->
      $('.drag-files').hide()

      onSubmit?(id, name)

    # Uploader options
    options =
      element: element[0]
      request:
        endpoint: element.attr('data-endpoint')
        inputName: 'uploaded_file'
        params:
          authenticity_token: $('meta[name="csrf-token"]').attr('content')

      callbacks: callbacks

      formatFileName: (name) ->
        if name.length > 20
          name = name.slice(0, 17) + '...'
        name

      dragAndDrop:
        hideDropzones: true

      text:
        uploadButton: I18n.t("uploader.button")
        cancelButton: I18n.t('_other.cancel')
        failUpload: I18n.t("uploader.fail")
        formatProgress: I18n.t("uploader.progress")
        waitingForResponse: I18n.t("uploader.processing")
        dragZone: I18n.t("uploader.drag_files")
        dropProcessing: I18n.t("uploader.processing")

      template: '<div class="qq-uploader">' +
        '<div class="qq-upload-drop-area upload-drag-and-drop"><i class="icon-upload-alt"></i></div>' +
        '<div class="upload-button btn btn-primary"><i class="icon-upload-alt"></i> {uploadButtonText}</div>' +
        '<span class="qq-drop-processing"><span>{dropProcessingText}</span><span class="qq-drop-processing-spinner"></span></span>' +
        '<ul class="upload-list qq-upload-list"></ul>' +
        if param_options.drag_and_drop then "<div class=\"drag-files\"><p><strong>#{I18n.t("or")}</strong></p><p class=\"badge\">{dragZoneText}</p></p>" else '' +
        '</div>'

      fileTemplate: "<li>" + "<div class=\"progress progress-striped active\"><div class=\"upload-progress-bar bar\"></div></div>" +
        "<span class=\"upload-spinner\"></span>" +
        "<span class=\"qq-upload-finished\"></span>" +
        "<p><span class=\"upload-file\"></span></p>" +
        "<span class=\"qq-upload-size\"></span>" +
        "<a class=\"qq-upload-cancel\" href=\"#\">{cancelButtonText}</a>" +
        "<a class=\"qq-upload-retry\" href=\"#\">{retryButtonText}</a>" +
        "<a class=\"qq-upload-delete\" href=\"#\">{deleteButtonText}</a>" +
        "<span class=\"qq-upload-status-text\">{statusText}</span>" + "</li>"

      classes:
        button: 'upload-button'
        progressBar: 'upload-progress-bar'
        spinner: 'upload-spinner'
        list: 'upload-list'
        file: 'upload-file'
        buttonHover: ''
        buttonFocus: ''

      validation: {}

    if element.attr('data-accept')
      options.validation.allowedExtensions = getFormatsFromFiles(element.attr('data-accept'))
      options.validation.acceptFiles = element.attr('data-accept')

    if element.attr('data-max-size')
      options.validation.sizeLimit = convertSize(element.attr('data-max-size'))

    uploader = new qq.FineUploader(options)

# Converts sizes like 1kb to 1024 bytes, 5mb to 5*1024^2 bytes and so on
convertSize = (str) ->
  units =
    kb: 1024
    mb: Math.pow(1024,2)
    gb: Math.pow(1024,3)
    tb: Math.pow(1024,4)

  validUnit = (unit) ->
    units.hasOwnProperty(unit)

  pattern = /([0-9]+)\s*([a-zA-Z]{2})|[0-9]+/
  result = pattern.exec(str.toLowerCase()) if str?

  if result?
    if result[1] and result[2] and validUnit(result[2]) # is in the form '5 mb'
      result[1] * units[result[2]]
    else if result[0]? && !result[1]? # is just a number of bytes
      result[0]
  else
    null

getFormatsFromFiles = (files) ->
  if files? && files == 'image/*'
    ['jpg', 'jpeg', 'png']