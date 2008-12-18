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
    if params[:space_id]
      @container = @space = Space.find_by_name(params[:space_id])
    elsif params[:id]
      @container = @space = Space.find_by_name(params[:id])
    elsif session[:space_id]
      @container = @space = Space.find_by_name(session[:space_id])
    else
      @container = @space = Space.find_by_name("Public")
    end 
    @space = @container = Space.find_by_id(1) if @space == nil
    session[:space_id] = @space.name
    @space_thumbnail = Logotype.find(:first, :conditions => {:parent_id => @space.logotype, :thumbnail => 'space'})
  end

  def get_site
    @site = Site.current
  end
end
