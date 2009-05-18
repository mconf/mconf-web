class SitesController < ApplicationController
  authorization_filter :manage, :site
end
