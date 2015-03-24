# Setups FineUploader on elements with the class .file-uploader

uploaderTemplate = HandlebarsTemplates['uploader/template']
uploaderFileTemplate = HandlebarsTemplates['uploader/file_template']

class mconf.Uploader

  @bind: (paramOptions) ->
    element = $('.file-uploader')

    # Add some behavior to the callbacks
    callbacks = paramOptions.callbacks or {}

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

      messages:
        typeError: I18n.t("uploader.error.invalid_extension")
        sizeError: I18n.t("uploader.error.invalid_size")
        emptyError: I18n.t("uploader.error.empty_file")
        noFilesError: I18n.t("uploader.error.no_files")
        onLeave: I18n.t("uploader.error.on_leave")

      text:
        uploadButton: I18n.t("uploader.button")
        cancelButton: I18n.t('_other.cancel')
        failUpload: I18n.t("uploader.fail")
        formatProgress: I18n.t("uploader.progress")
        waitingForResponse: I18n.t("uploader.processing")
        dragZone: I18n.t("uploader.drag_files")
        dropProcessing: I18n.t("uploader.processing")

      template: uploaderTemplate
        or: I18n.t("or")
        dragAndDrop: paramOptions.dragAndDrop

      fileTemplate: uploaderFileTemplate()

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
      options.validation.allowedExtensions = getFormatsFromAccept(element.attr('data-accept'))
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

getFormatsFromAccept = (accept) ->
  if accept? && accept == 'image/*'
    ['jpg', 'jpeg', 'png']

# Use this when firefox is ready to use the accepts='.jpg,.png, ...' (version 37 maybe)
getFileTypesFromAccept = (accept) ->
  formats = ('.' + format for format in getFormatsFromAccept(accept))
  formats.join(',')