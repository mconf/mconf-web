$(document).ready ->

  # move the subnav to be always in the top when the page is scrolled
  $("#subnav-wrapper").sticky()

  # activate the subnav links as the user scrolls in the page
  # TODO: this is not working, see <body> in layouts/frontpage.html
  # $("#subnav").scrollspy()

  # smoothly scroll when clicking in the navbar
  $("#subnav a.smooth").on "click", (e) ->
    e.preventDefault()
    $('html, body').animate
      scrollTop: $($(this).attr("href")).offset().top
    , 200

  # clicking in the login link goes to the top of the page and focus
  # the first input text
  $(".register-and-login a[href='#site']").on "click", ->
    $("#login-box > form > input").first().focus()
