require "digest/sha1"
class UsersController < ApplicationController
  # Include some methods and set some default filters. 
  # See documentation: CMS::Controller::Agents#included
  include CMS::Controller::Agents
  include CMS::Controller::Authorization


  # Get the User for member actions
  #before_filter :get_agent, :only => :show
  
  # Filter for activation actions
  before_filter :activation_required, :only => [ :activate, 
                                                 :forgot_password, 
                                                 :reset_password ]
  # Filter for password recovery actions
  before_filter :login_and_pass_auth_required, :only => [ :forgot_password,
                                                          :reset_password ]

  before_filter :get_space, :except=>[:new,:create,:activate,:forgot_password,:reset_password]
  
 before_filter :get_cloud
  before_filter :authentication_required, :only => [:show_space_users,:edit,:update, :manage_users, :destroy]
  before_filter :user_is_admin, :only=> [:manage_users, :search_users2]

  before_filter :edit_user,  :only=> [:show,:edit,:update,:destroy]
  before_filter :space_member, :only=>[:show,:show_space_users]

def index
 
end
def show
 
    @user = User.find(params[:id])
  end
  def show_space_users
  
  session[:current_tab] = "People" 
    @users = @container.actors
    
  end
  
  def create
    
    cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with 
    # request forgery protection.
    # uncomment at your own risk
    # reset_session    
    @agent = User.new(params[:agent])
    @agent.openid_identifier = session[:openid_identifier]
    @agent.save!
    tag = params[:tag][:add_tag]    
    @agent.tag_with(tag)
    @mail = @agent.email
    
    @invitation = Invitation.find_all_by_email(@mail)
    if @invitation!= nil
      for invitation in @invitation
       @space_id = invitation.space_id
       space= Space.find(@space_id)
      
      if space.container_performances.create :agent => @agent, :role => CMS::Role.find_by_id(invitation.role_id)
        invitation.destroy
      end
      end
    end
    
    flash[:notice] = "Thanks for signing up!. You have received an email with instruccions in order to activate your account."      
    redirect_back_or_default root_path
    rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end
  
  
  def manage_users
    session[:current_tab] = "Manage" 
    @users = User.find(:all)
  end
  
  
  #This method  debuggerreturns the user to show the form to edit him
  def edit
    @agent = User.find(params[:id])
    
  end
  def clean
    render :update do |page|
      page.replace_html 'search_results', ""
      
    end
  end
  
  
  #this method updates a user
  def update
  
    @user = User.find(params[:id])
    
    if @user.update_attributes(params[:user]) 
      #now we assign the machines to the user
      if current_user.superuser==true
        @array_resources = params[:resource]
        logger.debug("Array de maquinas es  " + @array_resources.to_s)
        @user.machines = Array.new        
        for machine in Machine.find(:all)
          if @array_resources[machine.name]=="1"
            logger.debug("Machine assign " + machine.name)
            @user.machines << machine              
          end            
        end
      end
     
      @user.save
      tag = params[:tag][:add_tag]    
      @user.tag_with(tag)
      flash[:notice] = 'User was successfully updated.'        
      
        #the superuser will be redirected to list_users
        if current_user.superuser == true
        redirect_to(manage_users_path(:space,@space.id))
    else
   redirect_to(space_user_profile_path(@space.id, @user.id)) 
             end
      
    else
      if current_user.superuser == true
        redirect_to(manage_users_path(:space,@space.id))
    else
   redirect_to(space_user_profile_path(@space.id, @user.id)) 
             end
     
    end
  end
  
  def destroy
    id = params[:id] 
    if id && user = User.find(id)
      user.destroy
      flash[:notice] = "User #{user.login} deleted"
    end
    redirect_to(:action => "manage_users")  
  end
  
  
  #search method that returns the users founded with the query in this space.
  def search_users
    @query = params[:query]
    q1 =  @query 
    @use = User.find_by_contents(q1)
    @users = []
    i = 0
   
    @agen = @container.actors

    @use.collect { |user|
    # debugger
      if @agen.include?(user)
          @users << user
      end
     }

    
    
    respond_to do |format|   
      format.html {render :template=>'/users/show_space_users'}
      format.js 
  
    end
  end
  
  
  #search method that returns the users founded with the query in all the aplication.
  def search_users2
    @query = params[:query]
    q1 =  @query 
    @users = User.find_by_contents(q1)
    
    respond_to do |format| 
       format.html {render :template=>'/users/manage_users'}
      format.js 
      #format.html 
    end
  end
  
  def reset_search
    q1 =  '*' 
    @users = User.find_by_contents(q1, :lazy=> [:login, :email, :name, :lastname, :organization])
    
    respond_to do |format|        
      format.js {render :template =>"users/search_users2.rjs"}
    end
  end
  
  def clean
    render :update do |page|
      page.replace_html 'adv_search', ""
      
    end
  end
  def search_by_tag
    
    @tag = params[:tag]
    # @users = User.tagged_with(@tag)   
    #@user = User.find_by_contents(@tag)
    @users = User.tagged_with(@tag)
    respond_to do |format|        
      format.js 
      #format.html 
    end
  end
  def organization
    respond_to do |format|
      # format.html 
      format.js   
    end
  end
  private
  def edit_user
  
    @agent = @user = User.find(params[:id])
    if current_user.superuser == true 
      return true
      
   elsif current_user.id == @user.id
      return true
    else
      flash[:notice] = "Action not allowed."          
      redirect_to root_path   
      end
  end
  
end
