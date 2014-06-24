#= require "../spaces/_sidebar"

$ ->
  # the sidebar is included in a lot of views, so we add them here to save us the
  # trouble of replicating it in all js's
  # TODO: this is actually bad, it is loading a lot of js in pages that don't need them,
  #   and causing pages to possible break because of this.
  mconf.Spaces.Sidebar.bind()
