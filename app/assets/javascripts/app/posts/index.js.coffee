
$ ->

  $("#new_post_submit").on 'click', ->
    $(this).data 'clicked', true

  $("#post_title").on 'click', ->
    $("#new_post_text").show "slow"

  $(document).on 'click', ->
    if !$("#post_title").is(":focus") and !$("#post_text").is(":focus") and !$("#new_post_submit").data("clicked")
      $("#new_post_text").hide 0