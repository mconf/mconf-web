class SitesController < ApplicationController
  before_filter :get_site
  authorization_filter :site, :update


    # GET /site/edit
  def edit
    session[:current_tab] = "Manage"
    session[:current_sub_tab] = "Site"
    @site = current_site
  end
  
  def get_space
   @container = @space = Space.find_by_name("Public")
  end

  def get_site
    @site = Site.current
  end
end
