#

$ ->
  $('.admin').on 'click', () ->
    updateRole(this, 2)

  $('.user').on 'click', () ->
    updateRole(this, 1)

updateRole = (el, role) ->
  id= $(el).parent().attr('data-form-id')
  input= $('input#'+id)
  input.val(role)
  form= input.closest('form')
  formUrl= form.attr('action')
  sendFormAjax(formUrl, form)
  setTimeout(lastAdminBlock, 100)

lastAdminBlock = () ->
  q= $('.admin.active')
  if q.length < 2
    q.closest('.btn-group').addClass('hidden')
    q.parent().siblings('.quit-space').addClass('hidden')
    q.parent().siblings('.help').removeClass('hidden')
  else
    q.closest('.btn-group').removeClass('hidden')
    q.parent().siblings('.quit-space').removeClass('hidden')
    q.parent().siblings('.help').addClass('hidden')

sendFormAjax = (url, data) ->
  $.ajax
    type: "POST"
    url: url
    data: data.serialize()
