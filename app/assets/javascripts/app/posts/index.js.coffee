$ ->
  if isOnPage 'posts', 'index'

    $("#new-post-submit").on 'click', ->
      $(this).data 'clicked', true

    $("#post_title").on 'click', ->
      $("#new-post-text").show 0

    $(document).on 'click', ->
      unless $("#post_title").is(":focus") or $("#post_text").is(":focus") or $("#new-post-submit").data("clicked")
        $("#new-post-text").hide 0