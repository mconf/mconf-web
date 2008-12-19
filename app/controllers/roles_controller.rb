class RolesController < ApplicationController
  before_filter :current_site
  authorization_filter :current_site, :manage
  
  
  # GET /roles
  # GET /roles.xml
  def index
    session[:current_tab] = "Manage"
    session[:current_sub_tab] = "Roles"
    @roles = Role.column_sort(params[:order], params[:direction]).all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @roles }
    end
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
  
end
