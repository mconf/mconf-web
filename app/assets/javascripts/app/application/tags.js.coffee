class mconf.Tags

  @bind: ->
    $(".toggle-tags").on 'click.mconfTags', (e) ->
      $parentElement = $(this).parent().parent()
      $('.more-tags', $parentElement).toggleClass("hidden")
      $(".label-tag-more", $parentElement).toggleClass("hidden")
      $(".label-tag-less", $parentElement).toggleClass("hidden")
      e.preventDefault()

$ ->
  mconf.Tags.bind()
