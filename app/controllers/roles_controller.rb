class RolesController < ApplicationController
  before_filter :current_site
  authorization_filter :current_site, :manage
end
