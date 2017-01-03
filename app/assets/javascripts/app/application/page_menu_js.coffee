# A page menu controlled via javascript. Instead of reloading the entire page when an
# item in the page menu is clicked, it simply changes the visible tab inside a div with
# all tabs, and marks the clicked menu item as active.
#
# Example:
#  #page-menu.page-menu-js
#    %li.active= link_to "Recent activity", "#tab-recent-activity"
#    %li= link_to "Spaces", "#tab-spaces"
#  #my-set-of-tabs
#    #tab-recent-activity
#      "My Content"
#    #tab-spaces
#      "My Content"
class mconf.PageMenuJs

  @bind: ->
    $(".page-menu-js li a").off "click.mconfPageMenuJs"
    $(".page-menu-js li a").on "click.mconfPageMenuJs", (e) ->
      e.preventDefault()
      mconf.PageMenuJs.change $(this)

  # Function to change the currently selected link/tab.
  # Receives the <a> tag in $target.
  @change: ($target) ->
    # deselect the current button/tab
    $target.parents(".page-menu-js").find("li a").each ->
      $menuLink = $(this)
      $menuLink.parents("li").removeClass("active")
      tab = $menuLink.attr("href")
      $(tab).hide()

    # select the target button/tab
    $target.parents("li").addClass("active")
    $($target.attr("href")).show()

$ ->
  # to hide the panels at startup
  mconf.PageMenuJs.change($(".page-menu-js li.active a"))

  mconf.PageMenuJs.bind()
