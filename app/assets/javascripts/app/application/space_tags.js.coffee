class mconf.SpaceTags

  @bind: ->
    if ("#space-tags").length

        showMoreTags = ->
          $(".toggle-tags").on 'click', (e) ->
            parentElement = $(this).parent().parent()
            $('.more-tags', $(this).parent().parent()).toggleClass("hidden")
            $(".label-tag-more", parentElement).toggleClass("hidden")
            $(".label-tag-less", parentElement).toggleClass("hidden")
            e.preventDefault()

        showMoreTags()

$ ->
  mconf.SpaceTags.bind()