require "digest/sha1"
class UsersController < CMS::AgentsController
   before_filter :authentication_required,  :only => [:edit, :update,:manage_users, :destroy]
  
  def forgot_password   
    return unless request.post?
    if @user = User.find_by_email(params[:email])
      @user.forgot_password
      @user.save
      Notifier.deliver_forgot_password(@user) if @user.recently_forgot_password?    
      flash[:notice] = "A password reset link has been sent to your email address"    
      redirect_to(:controller => '/events', :action => 'show')
      else
      flash[:notice] = "Could not find a user with that email address" 
    end
  end
  
  
def forgot_password2     
    if @user = User.find_by_id(params[:id])
      @user.forgot_password
      @user.save
      Notifier.deliver_forgot_password(@user) if @user.recently_forgot_password?    
      flash[:notice] = "A password reset link has been sent to the user  \"#{@user.login}\"  in order to reset his password"    
      redirect_to(:controller => '/users', :action => 'manage_users')
       else
      flash[:notice] = "Could not find a user with that email address" 
    end
  end
  
  
  def reset_password   
    @user = User.find_by_password_reset_code(params[:id])
    raise if @user.nil?
    return if @user unless params[:password]
      if (params[:password] == params[:password_confirmation])         
        self.current_user = @user #for the next two lines to work
        current_user.password_confirmation = params[:password_confirmation]
        current_user.password = params[:password]      
        @user.reset_password        
    Notifier.deliver_reset_password(@user) if @user.recently_reset_password?
        flash[:notice] = current_user.save ? "Password reset" : "Password not reset" 
      else
        flash[:notice] = "Password mismatch" 
      end  
      redirect_to(:controller => '/events', :action => 'show') 
  rescue
    logger.error "Invalid Reset Code entered" 
    flash[:notice] = "Sorry - That is an invalid password reset code. Please check your code and try again. (Perhaps your email client inserted a carriage return?" 
    redirect_to(:controller => '/events', :action => 'show')
  end
  
  
  def create
    cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with 
    # request forgery protection.
    # uncomment at your own risk
    # reset_session    
    @agent = @klass.new(params[:agent])            
    @agent.save!
    Notifier.deliver_confirmation_email(@agent)
    redirect_back_or_default('/')
    flash[:notice] = "Thanks for signing up!. You have received an email with instruccions in order to activate your account."      
  
    rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end
  

# create a hash to use when confirming User email addresses
def confirmation_hash(string)
  Digest::SHA1.hexdigest(string + "secret word")
end


  def manage_users
    @all_users = User.find(:all)
  end
  
  
  #This method returns the user to show the form to edit him
  def edit
      @user = User.find(params[:id])
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

end
