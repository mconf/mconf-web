$ ->

  if isOnPage 'frontpage', 'show'

    # move the subnav to be always in the top when the page is scrolled
    $("div#subnav-wrapper").sticky()

    # activate the subnav links as the user scrolls in the page
    # TODO: this is not working, see <body> in layouts/frontpage.html
    # $("div#subnav").scrollspy()

    # smoothly scroll when clicking in the navbar
    $("div#subnav a.smooth").on "click", (e) ->
      focus_input = $(this).attr("href") == "#site"
      $('html, body').animate
        scrollTop: $($(this).attr("href")).offset().top - $("div#subnav").height()
      , 300, ->
        # clicking in the login link goes to the top of the page and focus
        # the first input text
        $("div#login-box > form > input").first().focus() if focus_input
