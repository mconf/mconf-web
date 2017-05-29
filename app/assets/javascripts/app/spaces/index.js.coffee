# Used to keep elements in the sidebar always visible when the page is scrolled.
#= require jquery/jquery.sticky

$ ->
  if isOnPage 'spaces', 'index'

    # hovering an space shows its description in the sidebar
    $("#spaces .list-item").hover ->

      $("#space-description-wrapper .empty-space-description").hide()

      hovered = ".space-description#" + $(this).attr("name") + "-description"

      # mark the list item as active
      $("#spaces .list-item").removeClass('active')
      $(this).addClass('active')

      # hide all descriptions and shows the selected
      $("#space-description-wrapper .space-description").removeClass('active')
      $(hovered).addClass('active')

      # updates the position of the description div
      $("#space-description-wrapper").sticky("update")

    # move the space description in the sidebar to be always in
    # the visible space of the page when the page is scrolled
    $("#space-description-wrapper").sticky
      topSpacing: 20
      bottomSpacing: 250
