require "digest/sha1"
class UsersController < ApplicationController
   # Include some methods and set some default filters. 
   # See documentation: CMS::Controller::Agents#included
   include CMS::Controller::Agents

   before_filter :authentication_required, :only => [:edit, :update,:manage_users, :destroy]
  
  def create
    cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with 
    # request forgery protection.
    # uncomment at your own risk
    # reset_session    
    @agent = User.new(params[:agent])            
    @agent.save!
    redirect_back_or_default('/')
    flash[:notice] = "Thanks for signing up!. You have received an email with instruccions in order to activate your account."      
  
    rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end
  

  def manage_users
    @all_users = User.find(:all)
  end
  
  
  #This method returns the user to show the form to edit him
  def edit
      @user = User.find(params[:id])
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
          #debugger
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
        if current_user.superuser == true
        #the superuser will be redirected to list_users
        redirect_to :action => 'manage_users', :id => @user 
        else
          redirect_to(:action => "show", :controller => "events")
        end
    else
      render :action => 'edit'
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

def search_users
  @query = params[:query]
   q1 =  @query 
    @users = User.find_by_contents(q1, :lazy=> [:login, :email, :name, :lastname, :organization])

  respond_to do |format|        
      format.js 
     #format.html 
    end
  end
  def search_in_organization
    @query = params[:query]
   q1 = "organization:" + @query + "*" 
    @users = User.find_by_contents(q1, :lazy=> [:login, :email, :name, :lastname, :organization])

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
end
