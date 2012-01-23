$(document).ready ->

  # TODO: make this generic, to be used in any ajax request

  hideLoading = -> $("#latest-news .loading-icon").hide()
  showLoading = -> $("#latest-news .loading-icon").show()

  hideLoading()

  $("a[data-remote]").live 'ajax:beforeSend', showLoading
  $("a[data-remote]").live 'ajax:complete', hideLoading
