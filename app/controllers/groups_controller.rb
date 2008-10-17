class GroupsController < ApplicationController
  before_filter  :user_is_admin , :only=> [:index,:show, :new,:create, :edit,:update,:destroy]

  before_filter :authentication_required

  #before_filter :remember_tab_and_space

  before_filter :space_member, :only=>[:group_details,:index,:groups_details]

  authorization_filter :space, :manage_groups, :only=>[ :create_group,:save_group, :edit_group, :update_group, :delete_group]
  
  
  # GET /groups
  # GET /groups.xml
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
    end
    
    
  end
  
  # GET /groups/1
  # GET /groups/1.xml
  # GET /groups/1.txt
  def show
    @group = Group.find(params[:id])
    
    @users = @group.users
    
    respond_to do |format|
      format.html # show.html.erb
      format.js
      format.xml  { render :xml => @group }
      format.text  { render :text => @group.mail_list}
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
    @users =  @group.users   
    
  end
  
  # POST /groups
  # POST /groups.xml
  def create
    
=begin    
    @group = Group.new(params[:group])
    
    @group.users = Array.new #no vale sólo con la linea siguiente porque duplica los usuarios
    @group.users << User.find(:all)   
    
    @space = Space.find(params[:space_id])
    @group.space = @space
    
    respond_to do |format|
      if @group.save
        flash[:notice] = 'Group was successfully created.'
        format.html { redirect_to(@group) }
        format.xml  { render :xml => @group, :status => :created, :location => @group }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
=end    
    
    @group = Group.new()
    @group.space = @space
    @group.name = params[:group_name]
    array_users = Array.new
    @group.users = Array.new
    
    
    #rellenamos el array con los usuarios del grupo
    if params[:group_users] && params[:group_users][:id]
      array_users = params[:group_users][:id]
    end
    
    for id in array_users
      @group.users << User.find(:all, :conditions => {:id => id})
    end
    
    respond_to do |format|
      if @group.save
        
        flash[:notice] = 'Group was successfully created in this space.'
        format.html { redirect_to(space_groups_path(@space)) }
        format.xml  { render :xml => @group, :status => :created, :location => @group }
      else
        
        flash[:notice] = 'Error creating group.'
        
        @users_group = []
        format.html { redirect_to(new_space_group_path(@space)) }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # PUT /groups/1
  # PUT /groups/1.xml
  def update
    
    
=begin    
    @group = Group.find(params[:id])

    respond_to do |format|
      if @group.update_attributes(params[:group])
        flash[:notice] = 'Group was successfully updated.'
        format.html { redirect_to(@group) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
=end
    if params[:id] && params[:group_name] && params[:group_users]
      @group = Group.find(params[:id])
      @group.name = params[:group_name]
      @group.users = Array.new
      
                if params[:group_users] && params[:group_users][:id]
            array_users = params[:group_users][:id]
          end
          
          for id in array_users
            @group.users << User.find(:all, :conditions => {:id => id})
          end      
          
      
      
      respond_to do |format|        
        
        if @group.save
                 
          
          flash[:notice] = 'Group was successfully updated.'
          format.html { redirect_to(space_groups_path(@space)) }
          format.xml  { render :xml => @role, :status => :created, :location => @group }
        else         
          flash[:notice] = 'Error updating group.'       
          format.html { redirect_to(edit_space_group_path(@space,@group)) }
          format.xml  { render :xml => @role.errors, :status => :unprocessable_entity }
        end
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
    end
  end
  
end
