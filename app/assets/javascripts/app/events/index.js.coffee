# Used to keep elements in the sidebar always visible when the page is scrolled.
#= require jquery/jquery.sticky

$ ->
  if isOnPage 'events', 'index'

    # hovering an event shows its description in the sidebar
    $(".list-texts > li").hover ->

      # hide all descriptions and shows the selected
      hovered = "div#" + $(this).attr("name") + "-description"
      $("#event-description-wrapper div.content-block-middle").hide()
      $(hovered).show()

      # remove all 'selected' classes and adds only to the selected div
      $(".list-texts > li.selected").removeClass("selected")
      $(this).addClass("selected")

      # updates the position of the description div
      $("#event-description-wrapper").sticky("update")

    # move the event description in the sidebar to be always in
    # the visible event of the page when the page is scrolled
    $("#event-description-wrapper").sticky
      topSpacing: 20
      bottomSpacing: 250

    # how results are formatted in the search input
    format = (state) ->
      if state.public
        r = "<i class='icon icon-eye-open icon-space-public'></i>"
      else
        r = "<i class='icon icon-lock icon-space-private'></i>"
      "#{r}<a href='#{state.url}'>#{state.text}</a>"

    # redirects to the space when an item is clicked in the search input
    $("#event_filter_text").on "change", (e) ->
      window.location = e.added.url if e.added?.url?

    # select input to search for events
    $("#event_filter_text").select2
      minimumInputLength: 1
      placeholder: I18n.t('events.index.search.by_name.placeholder')
      formatNoMatches: (term) ->
        I18n.t('events.index.search.by_name.no_matches', { term: mconf.Base.escapeHTML(term) })
      width: '250'
      formatResult: format
      formatSelection: format
      ajax:
        url: '/events/select.json?limit=10'
        dataType: 'json'
        data: (term, page) ->
          q: term
        results: (data, page) ->
          results: data
