# This class contains all the simple functionally to display a copy to clipboard modal 
# in divs which contain the class 'copyable-field' and nested within an input field and a anchor tag 

class mconf.CopyModal

  @bindAll:
    $('.copyable-field').each ->
      text = $('input', this).val()

      $('a', this).click ->
        mconf.Modal.showWindow
          target: '#copy-to-clipboard-modal'

        $('input#copy-to-clipboard-field').val(text)

        $('input#copy-to-clipboard-field').select()
        $('#copy-to-clipboard-modal').click ->
          $('input', this).select()

        $('input#copy-to-clipboard-field').keydown (e) ->
          # Detect ctrl+c being pressed
          if e.keyCode == 67 and e.ctrlKey
            $('#success-message').show(300)
            $(this).addClass('success')
            window.setTimeout( ->
              mconf.Modal.closeWindows()
              $('#success-message').hide()
            , 800)
            true
          else
            # other key inputs are ignored so we don't lose the
            # content of the input field
            false
