$ ->
  if isOnPage 'errors'
    # make the logo 'fall' on mouse over
    $("body.errors #content .logo").on "mouseover", () ->
      $(this).addClass "fall"
