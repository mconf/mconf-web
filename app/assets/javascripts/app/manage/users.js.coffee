$(document).ready ->
  $("#users_filter_text").select2
    minimumInputLength: 1
    placeholder: I18n.t('spaces.index.search.by_name.placeholder')
    formatNoMatches: (term) ->
      I18n.t('spaces.index.search.by_name.no_matches', { term: term })
    width: 'resolve'
    ajax:
      url: '/users/select.json'
      dataType: 'json'
      data: (term, page) ->
        q: term
      results: (data, page) ->
        results: $("#users-list").html "<%= j render :partial => 'manage/update_users_list'  %>"