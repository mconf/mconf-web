# http://dense13.com/blog/2009/05/03/converting-string-to-slug-javascript/
string_to_slug = (str) ->
  str = str.replace(/^\s+|\s+$/g, '')
  str = str.toLowerCase()

  # remove accents, swap ñ for n, etc
  from = "ãàáäâẽèéëêĩìíïîõòóöôũùúüûñçć·/_,:;!"
  to   = "aaaaaeeeeeiiiiiooooouuuuuncc-------"
  for i in [0..from.length]
    str = str.replace(new RegExp(from.charAt(i), 'g'), to.charAt(i))

  str.replace(/[^a-z0-9 -]/g, '') # remove invalid chars
     .replace(/\s+/g, '-') # collapse whitespace and replace by -
     .replace(/-+/g, '-') # collapse dashes

class window.mconf.SignupForm
  @setup: ->
    $fullname = $("#user__full_name")
    $username = $("#user_username")
    $username.attr "value", string_to_slug($fullname.attr("value"))
    $fullname.on "input keyup", () ->
      $username.attr "value", string_to_slug($fullname.attr("value"))
