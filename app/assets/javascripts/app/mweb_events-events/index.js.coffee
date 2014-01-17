# Used to keep elements in the sidebar always visible when the page is scrolled.
#= require jquery/jquery.sticky

$ ->
  if isOnPage 'mweb_events-events', 'index'

    # hovering an event shows its description in the sidebar
    $(".list-thumbnails > li, .list-texts > li").hover ->

      # hide all descriptions and shows the selected
      hovered = "div#" + $(this).attr("name") + "-description"
      $("#event-description-wrapper div.content-block-middle").hide()
      $(hovered).show()

      # remove all 'selected' classes and adds only to the selected div
      $(".list-thumbnails > li.selected, .list-texts > li.selected").removeClass("selected")
      $(this).addClass("selected")

      # updates the position of the description div
      $("#event-description-wrapper").sticky("update")

    # move the event description in the sidebar to be always in
    # the visible event of the page when the page is scrolled
    $("#event-description-wrapper").sticky
      topSpacing: 20
      bottomSpacing: 250
