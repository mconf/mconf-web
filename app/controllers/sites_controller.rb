# Require Station Controller
require_dependency "#{ RAILS_ROOT }/vendor/plugins/station/app/controllers/sites_controller"

class SitesController
  authorization_filter :manage, :site
end
