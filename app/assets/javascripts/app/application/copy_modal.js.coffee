template = HandlebarsTemplates['application/copy_modal']
dialogId = '#copy-to-clipboard-modal'

# This class contains all the simple functionally to display a copy to clipboard modal
# in divs which contain the class 'copyable-field' and nested within an input field and a anchor tag
class mconf.CopyModal

  @bind:
    $('.copyable-field').each ->
      text = $('input', this).val()

      $('a', this).click ->
        params =
          title: I18n.t('_js.copy_modal.title')
          message: I18n.t('_js.copy_modal.message')
        mconf.Modal.showWindow
          data: template(params)

        input = $('input', dialogId)
        input.val(text)
        input.select()

        $(dialogId).click -> $('input', this).select()

        input.keydown (e) ->
          # Detect ctrl+c being pressed
          if e.keyCode == 67 and e.ctrlKey
            $('#copy-to-clipboard-message', dialogId).show()
            $('#copy-to-clipboard-title', dialogId).hide()
            $(dialogId).addClass('success')
            window.setTimeout( ->
              mconf.Modal.closeWindows()
              $('#copy-to-clipboard-message', dialogId).hide()
              $('#copy-to-clipboard-title', dialogId).show()
              $(dialogId).removeClass('success')
            , 1000)
            true
          else
            # other key inputs are ignored so we don't lose the
            # content of the input field
            false
