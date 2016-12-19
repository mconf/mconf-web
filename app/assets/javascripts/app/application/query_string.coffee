# Component used to edit the query string of a page based on data attributes
# set on links.
#
# To change a parameter:
#   data-qstring="my_spaces=true"
#
# To remove a parameter:
#   data-qstring="my_spaces="
#
# To add a value to a parameter:
#   data-qstring="tag+=dois" data-qstring-sep=","
#
# To remove a value from a parameter:
#   data-qstring="tag-=dois" data-qstring-sep=","

class mconf.QueryString

  @bind: ->
    $(document).on 'click.mconfQueryString', 'a[data-qstring]', (e) -> onClick(e)

onClick = (event) ->
  event.preventDefault()

  $target = $(event.target)
  url = new URL(window.location)
  query = mconf.Base.parseQueryString(url.search)

  qstring = $target.data('qstring')
  sep = $target.data('qstring-sep')

  if qstring.indexOf('+=') != -1
    query = addParam(query, qstring, sep)
  else if qstring.indexOf('-=') != -1
    query = removeParam(query, qstring, sep)
  else if qstring.indexOf('=') != -1
    query = replaceParam(query, qstring)
  else
    return

  url.search = mconf.Base.makeQueryString(query)
  # TODO: if $target has href, use it instead of window.location
  window.location = url.toString()

# Replaces the value of a parameter in the query string e.g. turns
# "tag=one" into "tag=two".
# `query` must be an object with the parameters
# `qstring` is the key/value pair in the format "key=value"
replaceParam = (query, qstring) ->
  param = qstring.split('=')[0]
  value = qstring.split('=')[1]
  if value.trim() is ''
    delete query[param] if query[param]?
  else
    query[param] = value
  query

# Adds a value to a parameter to the query string e.g. turns "tag=one"
# into "tag=one,two".
# `query` must be an object with the parameters
# `qstring` is the key/value pair in the format "key+=value"
# `sep` is the character used to separate values inside the parameter.
addParam = (query, qstring, sep) ->
  param = qstring.split('+=')[0]
  value = qstring.split('+=')[1]

  if value? and value.trim() isnt ''
    if query[param]
      unless query[param].match(value) # no duplicates
        query[param] = query[param] + sep + value
    else
      query[param] = value

  query

# Removes a value from a parameter in the query string e.g. turns
# "tag=one,two" into "tag=one".
# `query` must be an object with the parameters
# `qstring` is the key/value pair in the format "key-=value"
# `sep` is the character used to separate values inside the parameter.
removeParam = (query, qstring, sep) ->
  param = qstring.split('-=')[0]
  value = qstring.split('-=')[1]

  # remove the value, if any
  query[param] = query[param].replace(value, '') if value and value.trim() isnt ''

  # remove separators from the beginning and end
  query[param] = query[param].replace(new RegExp('^' + sep), '')
  query[param] = query[param].replace(new RegExp(sep + '$'), '')
  # no more than one separator together
  query[param] = query[param].replace(new RegExp(sep + '+'), sep)

  # if the param was left empty, remove it
  delete query[param] if not query[param]? or query[param].trim() is ''

  query

$ ->
  mconf.QueryString.bind()
