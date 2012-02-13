$(document).ready ->

  # activate the subnav links as the use scrolls in the page
  $("#subnav").scrollspy
    offset: 50 # TODO: the offset is nor working

  # clicking in the login link goes to the top of the page and focus
  # the first input text
  $(".register-and-login a[href='#site']").on "click", ->
    $("#login-box > form > input").first().focus()

  # move the subnav to be always in the top when the page is scrolled
  $("#subnav-wrapper").sticky()
