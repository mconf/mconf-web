# Setups FineUploader on elements with the class .file-uploader

class mconf.Uploader

  @bindAll: (callbacks) ->
    element = $('.file-uploader')
    uploader = new qq.FineUploader
      element: element[0]
      request:
        endpoint: element.attr('data-endpoint')
        inputName: 'uploaded_file'
        params:
          authenticity_token: $('meta[name="csrf-token"]').attr('content')

      validation:
        allowedExtensions: getFormatsFromFiles(element.attr('data-accept'))
        acceptFiles: element.attr('data-accept')
        sizeLimit: convertSize(element.attr('data-max-size'))

      callbacks: callbacks

      formatFileName: (name) ->
        if name.length > 20
          name = name.slice(0, 17) + '...'
        name

      # No drag and drop
      dragAndDrop:
        disableDefaultDropzone: true

      template: '<div class="qq-uploader">' +
        '<div class="upload-button btn btn-primary">{uploadButtonText}</div>' +
        '<span class="qq-drop-processing"><span>{dropProcessingText}</span><span class="qq-drop-processing-spinner"></span></span>' +
        '<ul class="upload-list qq-upload-list"></ul>' +
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
        file: 'upload-file'
        progressBar: 'upload-progress-bar'
        spinner: 'upload-spinner'
        list: 'upload-list'
        buttonHover: ''
        buttonFocus: ''

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
  result = pattern.exec(str.toLowerCase())

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