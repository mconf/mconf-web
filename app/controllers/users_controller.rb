require "digest/sha1"
class UsersController < ApplicationController
  include ActionController::Agents
  
  before_filter :space!, :only => [ :index ]
  before_filter :agent, :only => [ :show, :edit, :update, :destroy ]

  # Permission filters
  authorization_filter [ :read, :performance ], :space, :only => [ :index ]
  before_filter :authentication_required, :only => [:edit, :update, :destroy]
  # Accounts
  before_filter :user_is_current_agent, :only => [ :show, :edit, :update ]
  authorization_filter :delete, :user, :only => [ :destroy ]

=begin
  # Filter for activation actions
  before_filter :activation_required, :only => [ :activate, 
                                                 :lost_password, 
                                                 :reset_password ]
  # Filter for password recovery actions
  before_filter :login_and_pass_auth_required, :only => [ :lost_password,
                                                          :reset_password ]
=end

  set_params_from_atom :user, :only => [ :create, :update ]  
  
  # GET /users
  # GET /users.xml
  # GET /users.atom
  
  def index
    @users = space.users.sort {|x,y| x.name <=> y.name }
    @groups = @space.groups.all(:order => "name ASC")
    @users_without_group = @users.select{|u| u.groups.select{|g| g.space==@space}.empty?}
    if params[:edit_group]
      @editing_group = @space.groups.find(params[:edit_group])
    else
      @editing_group = Group.new()
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
    render :partial => "register" if request.xhr?
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
        self.current_agent = @user
        flash[:notice] = "Thanks for registering! We have just sent instructions on how to activate your user account permanently." 
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
    
    respond_to do |format|
      if @user.update_attributes(params[:user])
        @user.tag_with(params[:tags]) if params[:tags]
        
        flash[:success] = 'User was successfully updated.'     
        format.html { #the superuser will be redirected to list_users
          redirect_to(user_profile_path(@user))
        } 
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
    #debugger
    #@user = User.find(params[:id])
    #@user.update_attribute :disabled,true
    @user.disable
    
    flash[:notice] = "User #{@user.login} deleted"
    
    respond_to do |format|
      format.html {
        if !@space && current_user.superuser?
          redirect_to manage_users_path
        elsif !@space
          redirect_to root_path
        else
          redirect_to(space_users_path(@space))
        end
      }
      format.xml  { head :ok }
      format.atom { head :ok }
    end
  end

  def user_is_current_agent
    return if current_agent.superuser?

    not_authorized unless current_agent == @user
  end
end
