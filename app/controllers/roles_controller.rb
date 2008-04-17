
class RolesController < ApplicationController
  include CMS::Controller::Base
  before_filter :authentication_required
  before_filter :get_container , :only=>[:group_details, :create_group,:save_group, :show_groups, :delete_group]
  def index
    @role = CMS::Role.find_all_by_is_group(false)
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @role }
    end
  end
  
  
  def show
    @role = CMS::Role.find(params[:id] )
    
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @role }
    end
  end
  
  # GET /roles/new
  # GET /roles/new.xml
  def new
    @role = CMS::Role.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @role }
    end
  end
  
  # GET /roles/1/edit
  def edit
    @role = CMS::Role.find(params[:id])
  end
  
  
  # POST /roles
  # POST /roles.xml
  def create
    
    @role = CMS::Role.new(params[:cms_role])
    
    @role.is_group = false
    respond_to do |format|
      if @role.save
        flash[:notice] = 'Role was successfully created.'
        format.html { redirect_to(:action => "index", :controller => "roles") }
        format.xml  { render :xml => @role, :status => :created, :location => @role }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @role.errors, :status => :unprocessable_entity }
      end
    end
  end
  # PUT /roles/1
  # PUT /roles/1.xml
  def update
    debugger
    @role = CMS::Role.find(params[:id])
    
    respond_to do |format|
      if @role.update_attributes(params[:cms_role])
        flash[:notice] = 'Role was successfully updated.'
        format.html { redirect_to(:action => "index", :controller => "roles") }
        format.xml  { head :ok }
      else
        format.html { render :action => "index" }
        format.xml  { render :xml => @role.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # DELETE /roles/1
  # DELETE /roles/1.xml
  def destroy
    @role = CMS::Role.find(params[:id])
    @role.destroy
    
    respond_to do |format|
      format.html { redirect_to(roles_url) }
      format.xml  { head :ok }
    end
  end
  
  def group_details
    
    @role = CMS::Role.find(params[:group_id])
    @performances = CMS::Performance.find_all_by_role_id_and_container_id(@role.id, @container.id)
    i = 0
    @users = []
    for performance in @performances
      
      @users [i] = User.find(performance.agent_id)
      i = i+ 1
    end
    
    respond_to do |format|
      format.js
      format.xml  { render :xml => @role }
    end
  end
  def show_groups
    
    ###estan deben ser unicas...
    @perf = CMS::Performance.find_all_by_container_id(params[:container_id])
    
    @perf = @perf.collect{ |p| p.role_id}.uniq
    i = 0
    @role = []
    for perf in @perf
  
      @part = CMS::Role.find_by_is_group_and_id(true,perf)
      if @part == nil
        
      else
        @role[i]=@part
        i = i+ 1
      end
  
      
    end
        
    respond_to do |format|
      format.html 
      format.xml  { render :xml => @role }
    end
  end
  
  def create_group 
    @users =  @container.agents    
    @role = CMS::Role.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @role }
    end
    
  end
  def save_group
    
    @rol = CMS::Role.find(params[:role][:id])
    
    @role = CMS::Role.new(:is_group=>:true, :name => params[:cms_role][:name],:create_posts => @rol.create_posts, :read_posts => @rol.read_posts, :update_posts => @rol.update_posts, :delete_posts => @rol.delete_posts, :create_performances => @rol.create_performances, :read_performances => @rol.read_performances,:update_performances => @rol.update_performances, :delete_performances => @rol.delete_performances, :manage_events => @rol.manage_events, :admin => @rol.admin)
    
    
    respond_to do |format|
      if @role.save
        if params[:users] && params[:users][:id]             
          for id in params[:users][:id]
            @container.performances.create :agent => User.find(id), :role => @role
          end          
        end
        flash[:notice] = 'Group was successfully created in this space.'
        format.html { redirect_to(:action => "show_groups", :controller => "roles") }
        format.xml  { render :xml => @role, :status => :created, :location => @role }
      else
        format.html { render :action => "create_group" }
        format.xml  { render :xml => @role.errors, :status => :unprocessable_entity }
      end
    end
    
  end
  
  def delete_group
    
    
    @role = CMS::Role.find(params[:group_id])
    
    
    @performances = CMS::Performance.find_all_by_role_id_and_container_id(params[:group_id], @container.id)
    
    for performance in @performances
      performance.destroy
    end
    @role.destroy
    flash[:notice] = 'Group was successfully deleted'
    redirect_to(:action => "show_groups", :controller => "roles") 
    
  end
end
