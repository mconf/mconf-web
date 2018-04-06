container = '#feedback-form'
subjectSelector = '#feedback_subject'
messageSelector = '#feedback_message'
submitSelector = 'input[type=\'submit\']'

mconf.Feedback or= {}

class mconf.Feedback

  @bind: ->
    feedback = new mconf.Feedback()
    feedback.checkRequired()
    feedback.bindRequired()

  @unbind: ->
    # TODO: can it be done?

  # Dont enable the form button unless user has filled in users and title
  checkRequired: ->
    hasSubject = $(subjectSelector).val()?.length > 0
    hasMessage = $(messageSelector).val()?.length > 0

    if hasSubject and hasMessage
      $(submitSelector, container).removeAttr('disabled')
    else
      $(submitSelector, container).attr('disabled','disabled')

  bindRequired: ->
    $(subjectSelector).on "keydown keyup", =>
      @checkRequired()
    $(messageSelector).on "keydown keyup", =>
      @checkRequired()