#= require "../spaces/_sidebar"

$ ->
  # the sidebar is included in a lot of views, so we add them here to save us the
  # trouble of replicating it in all js's
  mconf.Spaces.Sidebar.bind()
