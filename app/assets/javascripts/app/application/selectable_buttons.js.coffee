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

# Function to change the currently selected button/tab
selectableButtonsChange = (target) ->

  # deselect the current button/tab
  $("div.selectable-buttons-target > div").hide()
  $("ul.selectable-buttons a").each ->
    $(this).removeClass("selected")

  # select the target button/tab
  target.addClass("selected")
  $(target.attr("href")).show()

$ ->

  # to hide the panels at startup
  selectableButtonsChange $("ul.selectable-buttons a.selected")

  $("ul.selectable-buttons a").on "click", (e) ->
    e.preventDefault()
    selectableButtonsChange $(this)
