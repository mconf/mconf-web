$(document).ready ->

  # clicking the items in the components menu changes the component
  # active in the slider
  $("#components-menu .content-block").livequery "click", ->
    linkIndex = $(this).prevAll().length
    updateComponentsMenu linkIndex + 1, 1

  # method to update the component visible in the slider
  # and the item selected in #components-menu
  # updates the slider if 'update' is true
  updateComponentsMenu = (index, update) ->
    sel = $("#components-menu .content-block-selected")
    sel.removeClass "content-block-selected"
    sel.addClass "content-block"
    obj = $("#components-menu .content-block:eq(" + (index - 1) + ")")
    obj.removeClass "content-block"
    obj.addClass "content-block-selected"
    $("#components-images").anythingSlider index  if update?

  # updates the item selected in #components-menu
  updateComponentsSlider = (slider) ->
    cap = slider.$currentPage.find(".caption").html()
    $("#components-description .content").html(cap).fadeIn 200

  # the component slider
  $("#components-images").anythingSlider
    theme: "default"
    expand: false
    resizeContents: false
    easing: "swing"
    buildArrows: false
    buildNavigation: false
    buildStartStop: true
    startText: "Start"
    stopText: "Stop"
    enableArrows: false
    enableNavigation: false
    enableStartStop: true
    enableKeyboard: true
    autoPlay: true
    autoPlayLocked: false
    resumeDelay: 15000
    autoPlayDelayed: false
    delay: 8000
    animationTime: 300
    onSlideBegin: (e, slider) ->
      $("#components-description .content").fadeOut 200
      updateComponentsMenu slider.targetPage
    onInitialized: (e, slider) ->
      updateComponentsSlider slider
      updateComponentsMenu slider.currentPage
    onSlideComplete: (slider) ->
      updateComponentsSlider slider
      updateComponentsMenu slider.currentPage
