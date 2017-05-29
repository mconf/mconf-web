# We use tooltips from bootstrap, so all we have to do is associate the proper elements
# calling bootstrap's `tooltip()`.
class mconf.ClipboardCopy

  @bind: ->
    $('.clipboard-copy').each ->
      clipboardBtn = new Clipboard(this)
      clipboardBtn.on 'success', (e)->
        showTooltip(e.trigger,'Copied!')
      $(this).on 'mouseout', (e)->
        mconf.Tooltip.unbindOne(e.target)

  @unbind: ->
  
$ ->
  mconf.ClipboardCopy.bind()

showTooltip = (elem,msg) ->
  elem.setAttribute('title',msg)
  mconf.Tooltip.bindOne(elem)
  mconf.Tooltip.show(elem)