# Dropdown menus, using twitter's bootstrap lib
class mconf.Dropdown
  @bind: ->
    $('.dropdown-toggle').dropdown()

$ ->
  mconf.Dropdown.bind()
