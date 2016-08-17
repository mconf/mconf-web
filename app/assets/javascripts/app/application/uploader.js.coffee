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
      options.validation.allowedExtensions = getAcceptedFormats(element.attr('data-accept'))
      options.validation.acceptFiles = element.attr('data-accept')

    if element.attr('data-max-size')
      options.validation.sizeLimit = element.attr('data-max-size')

    uploader = new qq.FineUploader(options)

getAcceptedFormats = (accept) ->
  formats = accept.split(',')

  format.replace('.', '') for format in formats
