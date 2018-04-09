emailSelector = '#user_email'
submitSelector = 'input[type=\'submit\']'

$ ->
  if isOnPage 'passwords', 'new'
    checkRequired()

    $(emailSelector).on "keydown keyup", =>
      checkRequired()

checkRequired = ->
  hasEmail = $(emailSelector).val()?.length > 0

  if hasEmail
    $(submitSelector).removeAttr('disabled')
  else
    $(submitSelector).attr('disabled','disabled')
