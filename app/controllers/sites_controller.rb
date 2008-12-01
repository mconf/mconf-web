class SitesController < ApplicationController
  before_filter :get_site
  authorization_filter :site, :update

  def get_space
   @container = @space = Space.find_by_name("Public")
  end

  def get_site
    @site = Site.current
  end
end
