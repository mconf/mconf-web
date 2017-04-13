container = '#webconference-invitation'
usersSelector = '#invite_users'
searchUsersUrl = '/users/select?limit=7'
startsOnSelector = '#invite_starts_on_time'
titleSelector = '#invite_title'
submitSelector = 'input[type=\'submit\']'

mconf.CustomBigbluebuttonRooms or= {}

class mconf.CustomBigbluebuttonRooms.Invitation

  @bind: ->
    invitation = new mconf.CustomBigbluebuttonRooms.Invitation()
    invitation.checkRequired()
    invitation.bindUsers()
    invitation.bindDates()
    invitation.bindRequired()

  @unbind: ->
    # TODO: can it be done?

  # Dont enable the form button unless user has filled in users and title
  checkRequired: ->

    # TODO: REQUIRE DATES

    hasTitle = $(titleSelector).first()?.val()?.length > 0
    hasInvitee = $(usersSelector).val()?.length > 0

    if hasTitle and hasInvitee
      $(submitSelector, container).removeAttr('disabled')
    else
      $(submitSelector, container).attr('disabled','disabled')

  bindRequired: ->
    $(usersSelector).on "change", =>
      @checkRequired()
    $(titleSelector).on "keydown keyup", =>
      @checkRequired()

  bindUsers: ->
    $(usersSelector, container).select2
      minimumInputLength: 1
      width: 'resolve'
      multiple: true
      formatSearching: -> I18n.t('custom_bigbluebutton_rooms.invitation.users.searching')
      formatInputTooShort: -> I18n.t('custom_bigbluebutton_rooms.invitation.users.hint')
      formatNoMatches: -> I18n.t('custom_bigbluebutton_rooms.invitation.users.no_results')
      tags: true
      tokenSeparators: [",", ";"]
      createSearchChoice: (term, data) ->
        if mconf.Base.validateEmail(term)
          { id: term, text: term }
      formatSelection: (object, container) ->
        text = if object.name?
          object.name
        else
          object.text
        mconf.Base.escapeHTML(text)
      ajax:
        url: searchUsersUrl
        dataType: "json"
        data: (term, page) ->
          q: term # search term
        results: (data, page) -> # parse the results into the format expected by Select2.
          results: data

  bindDates: ->
    start = $(startsOnSelector)
    mconf.DateTimeInput.setDate(start, new Date())
    mconf.DateTimeInput.setStartDate(start, new Date())

    startChanged()
    $('.starts-at-wrapper .btn-group .btn').on 'click', ->
      startChanged(this)

    # when submitting, set the starts on date to now, so that
    # 'now' means when the user submitted the form
    $('form', container).on 'submit', ->
      setStartsOnToNow() if isNowSelected()

isNowSelected = ->
  selected = $('.starts-at-wrapper .btn.active').data('attr-value')
  selected is 0

startChanged = (el) ->
  setStartsOnToNow()

  if el
    selected = $(el).data('attr-value')
  else
    selected = $('.starts-at-wrapper .btn.active').data('attr-value')
  if selected is 0
    $(startsOnSelector).parent().hide()
  else
    $(startsOnSelector).parent().show()
    $(startsOnSelector).focus()

setStartsOnToNow = ->
  mconf.DateTimeInput.setDate(startsOnSelector, new Date())
