# Very similar to jquery tabs, but instead of tabs we have buttons
# And these buttons can be anywhere in the page, not necessarily above the panels
#
# Example:
#  %ul.selectable-buttons
#    %li= link_to "Recent activity", "#tab-recent-activity", :class => 'selected'
#    %li= link_to "Spaces", "#tab-spaces"
#  .selectable-buttons-target
#    #tab-recent-activity
#      ...
#    #tab-spaces
#      ...
#

class mconf.SelectableButtons

  @bind: ->
    $(".selectable-buttons a").off "click.mconfSelectableButtons"
    $(".selectable-buttons a").on "click.mconfSelectableButtons", (e) ->
      e.preventDefault()
      mconf.SelectableButtons.change $(this)

  # Function to change the currently selected button/tab
  @change: ($target) ->

    # deselect the current button/tab
    $("div.selectable-buttons-target > div").hide()
    $(".selectable-buttons a").each ->
      $(this).removeClass("active")

    # select the target button/tab
    $target.addClass("active")
    $($target.attr("href")).show()

$ ->
  # to hide the panels at startup
  mconf.SelectableButtons.change($(".selectable-buttons a.active"))

  mconf.SelectableButtons.bind()
