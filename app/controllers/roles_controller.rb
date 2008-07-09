
class RolesController < ApplicationController
  include CMS::Controller::Base
  include CMS::Controller::Authorization
  before_filter  :user_is_admin , :only=> [:index,:show, :new,:create, :edit,:update,:destroy]
  before_filter :authentication_required
   before_filter :get_cloud
  before_filter :get_space , :only =>[:group_details, :show_groups, :create_group,:save_group, :edit_group, :update_group, :delete_group]
  before_filter  :can__manage_groups__space__filter, :only=>[ :create_group,:save_group, :edit_group, :update_group, :delete_group]
  before_filter :remember_tab_and_space
  before_filter :space_member, :only=>[:group_details,:show_groups,:groups_details]
  
  def index
   
    session[:current_tab] = "Manage" 
    @role = CMS::Role.find_all_by_type(nil)
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
     @performances = CMS::Performance.find_all_by_role_id(@role.id)
     for performance in @performances
      performance.destroy
    end
    @role.destroy    
    respond_to do |format|
      format.html { redirect_to(roles_url) }
      format.xml  { head :ok }
    end
  end
  
  def group_details  
       
    @role = Group.find(params[:group_id])
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
       
    session[:current_tab] = "Groups" 
    ###estan deben ser unicas...
    @perf = CMS::Performance.find_all_by_container_id(params[:container_id])
    
    @perf = @perf.collect{ |p| p.role_id}.uniq
    i = 0
    @role = []
    for perf in @perf  
      @part = Group.find_by_id(perf)
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
      
    @users =  @container.actors    
    @role = Group.new
    @users_group = []
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @role }
    end    
  end
  
  
  def save_group
    @users =  @container.actors   
    @role = Group.new()
    @role.name = params[:group_name]
    @role.type = "Group"
    array_users = Array.new
    respond_to do |format|
      if @role.save
        for login in array_users
             @container.container_performances.create :agent => User.find_by_login(login), :role => @role
        end
        flash[:notice] = 'Group was successfully created in this space.'
        format.html { redirect_to(:action => "show_groups", :controller => "roles") }
        format.xml  { render :xml => @role, :status => :created, :location => @role }
      else
        
        flash[:notice] = 'Error creating group.'
       
        @users_group = []
        format.html { render :action => "create_group" }
        format.xml  { render :xml => @role.errors, :status => :unprocessable_entity }
      end
    end
    
  end
  
  
  def edit_group
       
    @users =  @container.actors    
    @role = Group.find(params[:group_id])
    @group = @role    #para que rellene automáticamente los campos
    @performances = CMS::Performance.find_all_by_role_id_and_container_id(@role.id, @container.id)
    i = 0
    @users_group = []
    for performance in @performances
      @users_group [i] = User.find(performance.agent_id)
      i = i+ 1
    end
    @edit = true
    respond_to do |format|
      format.html {render }
      format.xml  { render :xml => @role }
    end
  end
  
  
  def update_group
    @role = Group.find(params[:group_id])
    @performances = CMS::Performance.find_all_by_role_id_and_container_id(params[:group_id], @container.id)
    
    for performance in @performances
      performance.destroy
    end
    if params[:group_users]
      array_users =  parse_divs(params[:group_users].to_s)
    end
    if  array_users.length >0 && @role.update_attributes(params[:group])
      if params[:group_users]
        for login in array_users
            @container.container_performances.create :agent => User.find_by_login(login), :role => @role
        end
        flash[:notice] = 'Group was successfully updated.'
      else
        @role.destroy
        flash[:notice] = 'Group was successfully deleted.'
      end      
       redirect_to(:action => "show_groups", :controller => "roles")     
    end
  end
  
  
  def delete_group    
    @role = Group.find(params[:group_id])
    @performances = CMS::Performance.find_all_by_role_id_and_container_id(params[:group_id], @container.id)
    
    for performance in @performances
      performance.destroy
    end
    @role.destroy
    flash[:notice] = 'Group was successfully deleted'
    redirect_to(:action => "show_groups", :controller => "roles") 
    
  end
  
  
  private
  #method to parse the request for update from the server that contains
  #<div id=d1>ebarra</div><div id=d2>user2</div>...
  #returns an array with the user logins
  def parse_divs(divs)
    #REXML da un error de que no puede añadir al root element, voy a crear un root element en divs
    str = "<temp>"+divs+"</temp>"
    #remove the characters "\n\r\t" that javascript introduces
    str = str.tr("\r","").tr("\n","").tr("\t","")
    doc = REXML::Document.new(str)
    array = Array.new
    REXML::XPath.each(doc, "//div") { |p| 
      #if the div has the style attribute with the none param is because it has been moved to the bin
      if p.attributes["style"]
        if p.attributes["style"].include? "none"
          next
        end
      end
      array << p.text
      }
    return array
  end
  
  
end
