$ ->
  if isOnPage 'spaces', 'show'

    return
    # TODO: comment because there's no more news
    # Maybe use this for other parts of the interface?

    # hideLoading = -> $("#latest-news .icon-mconf-loading").hide()
    # showLoading = -> $("#latest-news .icon-mconf-loading").show()

    # # TODO: make this generic, to be used in any ajax request
    # hideLoading()
    # $(document).on 'ajax:beforeSend', "#latest-news a[data-remote]", showLoading
    # # TODO: it should be:
    # #   $(document).on 'ajax:complete', "#latest-news a[data-remote]", hideLoading
    # # but the ajax is replacing the div that contains the link a[data-remote] and
    # # so the ajax:complete event is never triggered. Maybe change the ajax to
    # # update just a part of the div.
    # $(document).on 'ajaxComplete', hideLoading
