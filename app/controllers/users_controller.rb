require "digest/sha1"
class UsersController < ApplicationController
  include ActionController::Agents
  
  
  # Get the User for member actions
  before_filter :get_agent, :only => [ :show, :edit, :update, :destroy ]
  
=begin
  # Filter for activation actions
  before_filter :activation_required, :only => [ :activate, 
                                                 :forgot_password, 
                                                 :reset_password ]
  # Filter for password recovery actions
  before_filter :login_and_pass_auth_required, :only => [ :forgot_password,
                                                          :reset_password ]
  
  before_filter :authentication_required, :only => [:edit, :update, :destroy]

  # Space Users

  authorization_filter :space, [ :read, :Performance ],   :if   => :get_space, 
                                                          :only => [ :index ]
=end
  before_filter :space, :only => [ :index ]

  # Accounts
  before_filter :user_is_current_agent, :only => [ :show, :edit, :update ]
  authorization_filter :user, :delete, :only => [ :destroy ]

  set_params_from_atom :user, :only => [ :create, :update ]  
  
  # GET /users
  # GET /users.xml
  # GET /users.atom
  
  def index
=begin
    if params[:manage]
      session[:current_tab] = "Manage" 
      session[:current_sub_tab] = "Users"
      @users = User.find(:all)
    elsif params[:space_id] && params[:space_id] != "Public"
      session[:current_tab] = "People" 
      session[:current_sub_tab] = ""
      @users = @space.actors 
    elsif params[:space_id] && params[:space_id] == "Public"
      session[:current_tab] = "People" 
      session[:current_sub_tab] = ""
      @users = User.find(:all)
    else
      @users = User.find(:all)
    end
    
    @users.sort
    @users = @users.paginate(:page => params[:page],:per_page => 10)
=end
    if params[:space_id]
      @users = @space.actors.sort {|x,y| x.name <=> y.name }
      @groups = @space.groups.all(:order => "name ASC")
      @users_without_group = @users.select{|u| u.groups.select{|g| g.space==@space}.empty?}
    end

    respond_to do |format|
      format.html
      format.xml { render :xml => @users }
      format.atom
    end

  end
  
  # GET /users/1
  # GET /users/1.xml
  # GET /users/1.atom 
  def show
    respond_to do |format|
      format.html
      format.xml { render :xml => @user }
      format.atom
      format.atomsvc
    end
  end
  
  # GET /users/new
  # GET /users/new.xml  
  def new
    @user = @agent = model_class.new
  end
  
  # POST /users
  # POST /users.xml
  # POST /users.atom
  # {"commit"=>"Sign up", "captcha"=>"FBIILL", "tags"=>"", "action"=>"create", 
  # "controller"=>"users", "user"=>{"password_confirmation"=>"prueba", "email2"=>"", "email3"=>"", 
  # "login"=>"julito", "password"=>"prueba", "email"=>"email@domain.com"}}
  
  def create
    cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with 
    # request forgery protection.
    # uncomment at your own risk
    # reset_session    
    @agent = @user = User.new(params[:user])
    if @user.respond_to?(:openid_identifier)
      @user.openid_identifier = session[:openid_identifier]
    end
    
    respond_to do |format|
      if @user.save_with_captcha 
        @user.tag_with(params[:tags]) if params[:tags]
        flash[:notice] = "Thanks for registering! We have just sent instructions on how to activate your user account." 
        format.html { redirect_back_or_default root_path }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
        format.atom { 
          headers["Location"] = formatted_user_url(@user, :atom )
          render :action => 'show',
          :status => :created
        }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
        format.atom { render :xml => @user.errors.to_xml, :status => :bad_request }
      end
    end
    
  end
  
  #This method returns the user to show the form to edit him
  def edit
    session[:current_sub_tab] = "Edit Your Account"
    if @user.profile
      @thumbnail = Logotype.find(:first, :conditions => {:parent_id => @user.profile.logotype, :thumbnail => 'photo'})
    end
  end
  
  def clean
    render :update do |page|
      page.replace_html 'search_results', ""
      
    end
  end
  
  # PUT /users/1
  # PUT /users/1.xml
  # PUT /users/1.atom
  #this method updates a user
  def update
    #now we assign the machines to the user
    if current_user.superuser==true && params[:resource]
      @array_resources = params[:resource]
      logger.debug("Array de maquinas es  " + @array_resources.to_s)
      machines = Array.new        
      for machine in Machine.find(:all)
        if @array_resources[machine.name]=="1"
          logger.debug("Machine assign " + machine.name)
          machines << "#{machine.id}"              
        end            
      end
    end
    params[:user][:machine_ids] = machines
    
    
    respond_to do |format|
      if @user.update_attributes(params[:user])
        @user.tag_with(params[:tags]) if params[:tags]
        
        flash[:notice] = 'User was successfully updated.'     
        format.html { #the superuser will be redirected to list_users
          if current_user.superuser == true
            redirect_to(space_users_path(@space))
          else
            redirect_to(space_user_profile_path(@space, @user)) 
          end }
        format.xml  { render :xml => @user }
        format.atom { head :ok }
      else
        format.html { #the superuser will be redirected to list_users
          if current_user.superuser == true
             render :action => "edit" 
            #redirect_to(space_users_path(@space))
          else
             render :action => "edit" 
            #redirect_to(space_user_profile_path(@space, @user)) 
          end }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
        format.atom { render :xml => @user.errors.to_xml, :status => :not_acceptable }
      end
    end 
    
  end
  
  
  # DELETE /users/1
  # DELETE /users/1.xml  
  # DELETE /users/1.atom
  def destroy
    @user = User.find(params[:id])
    @user.destroy
    
    flash[:notice] = "User #{@user.login} deleted"
    
    respond_to do |format|
      format.html {  redirect_to(space_users_path(@space))  }
      format.xml  { head :ok }
      format.atom { head :ok }
    end
  end

  def user_is_current_agent
    return if current_agent.superuser?

    not_authorized unless current_agent == @user
  end
end
