class GroupsController < ApplicationController
  before_filter  :user_is_admin , :only=> [:index,:show, :new,:create, :edit,:update,:destroy]

  before_filter :authentication_required

  #before_filter :remember_tab_and_space

  before_filter :space_member, :only=>[:group_details,:index,:groups_details]

#  authorization_filter :space, :manage_groups, :only=>[ :create_group,:save_group, :edit_group, :update_group, :delete_group]
  authorization_filter :space, [ :manage, :Group ]
  
  set_params_from_atom :group, :only => [ :create, :update ]
  
  
  # GET /groups
  # GET /groups.xml
  # GET /groups.atom  
  def index
    
    session[:current_tab] = "Groups" 
    session[:current_sub_tab] = ""
    
    @groups = Group.find(:all)
    
    if (params[:space_id])
      @groups = Group.find(:all, :conditions => {:space_id => @space.id})
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @groups }
      format.atom
    end
    
    
  end
  
  # GET /groups/1
  # GET /groups/1.xml
  # GET /groups/1.txt
  # GET /groups/1.atom  
  def show
    @group = Group.find(params[:id])
    
    @users = @group.users
    
    respond_to do |format|
      format.html # show.html.erb
      format.js
      format.xml  { render :xml => @group }
      format.text  { render :text => @group.mail_list}
      format.atom
    end
  end
  
  # GET /groups/new
  # GET /groups/new.xml
  def new
    session[:current_sub_tab] = "Create Group"  
    @users =  @space.actors    
    @group = Group.new
    @users_group = []
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @group }
    end
  end
  
  # GET /groups/1/edit
  def edit
    @group = Group.find(params[:id])   
    @users =  @space.actors 
    
  end
  
  # POST /groups
  # POST /groups.xml
  # POST /groups.atom
  def create
    
    # estos arreglos se hacen porque la vista html no pasa bien los parámetros
    if params[:group_name] && params[:group_users]
      params[:group] = {}
      params[:group][:name] = params[:group_name]
      params[:group][:user_ids] = params[:group_users][:id]
    end
    
    params[:group][:space_id] = @space.id
    @group = Group.new(params[:group])
    respond_to do |format|
      if @group.save
        
        flash[:notice] = 'Group was successfully created in this space.'
        format.html { redirect_to(space_groups_path(@space)) }
        format.xml  { render :xml => @group, :status => :created, :location => @group }
        format.atom { 
          headers["Location"] = formatted_space_url(@group, :atom )
          render :action => 'show',
                 :status => :created
        }
      else
        
        flash[:notice] = 'Error creating group.'
        
        @users_group = []
        format.html { redirect_to(new_space_group_path(@space)) }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
        format.atom { render :xml => @group.errors.to_xml, :status => :bad_request }
      end
    end
  end
  
  # PUT /groups/1
  # PUT /groups/1.xml
  def update
    @group = Group.find(params[:id])     
    #here i save the param name in a variable for the callback    
    @old_name = @group.name
    
    #esto se hace porque la vista html no pasa bien los parámetros
    if params[:id] && params[:group_name] && params[:group_users]    
      params[:group] = {}
      params[:group][:name] = params[:group_name]
      params[:group][:user_ids] = params[:group_users][:id]     
  end
  
    params[:group][:space_id] = @space.id
      
      respond_to do |format|        
        
        if @group.update_attributes(params[:group])
          flash[:notice] = 'Group was successfully updated.'
          format.html { redirect_to(space_groups_path(@space)) }
          format.xml  { render :xml => @group, :status => :created, :location => @group }
          format.atom { head :ok }
        else         
          flash[:notice] = 'Error updating group.'       
          format.html { redirect_to(edit_space_group_path(@space,@group)) }
          format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
          format.atom { render :xml => @group.errors.to_xml, :status => :not_acceptable }
        end
      end

  end
  
  # DELETE /groups/1
  # DELETE /groups/1.xml
  def destroy
    @group = Group.find(params[:id])
    @group.destroy
    flash[:notice] = 'Group was successfully deleted'
    
    respond_to do |format|
      format.html { redirect_to(space_groups_url) }
      format.xml  { head :ok }
      format.atom  { head :ok }
    end
  end
  
end
