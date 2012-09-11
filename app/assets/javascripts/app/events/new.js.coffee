$ ->

  $("#open_gallery").on 'click', ->
    $("#default_upload_logo").hide 0
    $("#default_text_logo").hide 0
    $("#change_logo_form_div").show 0
    $("#default_space_images").show 0

  $("#close_logo_div").on 'click', ->
    $("#default_upload_logo").hide 0
    $("#default_text_logo").hide 0
    $("#default_space_images").hide 0
    $("#change_logo_form_div").hide 0

  $(".default_space_logo").on 'click', ->
    if $(this).attr 'data-image'
      image = $(this).attr 'data-image'
      $("#event_image").attr('value', "default_event_logos/" + image)
      $("#selected_logo_image").attr('src', "/assets/default_event_logos/" + image)
      $(".event_logo").show 0
      $(".event_date_image").hide 0


  $("#use_event_date").on 'click', ->
    $(".event_date_image").show "slow"
    $(".event_logo").hide "slow"
    $("#event_image").attr('value', "use_date_logo")
    $("#change_logo_form_div").hide 0
    $("#default_upload_logo").hide 0
    $("#default_text_logo").hide 0
    $("#default_space_images").hide 0

  $("#text_logo").on 'click', ->
    $("#default_upload_logo").hide 0
    $("#default_space_images").hide 0
    $("#change_logo_form_div").show 0
    $("#default_text_logo").show 0
    $("#open_text_logo_link").hide 0
    $("#close_text_logo_link").show 0

  $("#upload_logo").on 'click', ->
    $("#default_text_logo").hide 0
    $("#default_space_images").hide 0
    $("#change_logo_form_div").show 0
    $("#default_upload_logo").show 0
    $("#open_upload_logo_link").hide 0
    $("#close_upload_logo_link").show 0

  $("#generate_text_logo_button").on 'click', ->
    dateTime = new Date()
    rand = dateTime.getHours() + "" + dateTime.getMinutes() + "" + dateTime.getSeconds() + "" + dateTime.getMilliseconds()
    $.get '/logos/new?event_logo=true&text='+ ($("#event_text_logo").val()) + '&rand_name=' + rand , (data) ->
      $('#generated_text_logos').html data
    .complete ->
      $(".default_space_logo").on 'click', ->
        image = $(this).attr 'data-generate'
        $("#event_image").attr('value', image)
        $("#selected_logo_image").attr('src', $(this).attr 'src')
        $(".event_logo").show 0
        $(".event_date_image").hide 0