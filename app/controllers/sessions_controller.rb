# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  
  
  # render new.rhtml 
  def new
  end
  
  def create    
      self.current_user= User.authenticate(params[:login], params[:password])
      #debugger
       if  self.current_user!=:false && !self.current_user.email_confirmed    
        self.current_user.forget_me if logged_in?
        cookies.delete :auth_token
        reset_session        
        flash[:notice] = "Please confirm your registration. Click on the Url we have sended to your email address "
        render :action => 'new'
        return
      end
      if self.current_user!=:false && self.current_user.disabled        
        self.current_user.forget_me if logged_in?
        cookies.delete :auth_token
        reset_session        
        flash[:notice] = "Disabled user"
        render :action => 'new'
        return
      end
     
      if logged_in?
        if params[:remember_me] == "1"
          self.current_user.remember_me
          cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
        end
        redirect_back_or_default('/')
        flash[:notice] = "Logged in successfully"
      else
        flash[:notice] = "Invalid user/passwd combination.  " 
        render :action => 'new'
    end
  end
  
  
  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end
end
