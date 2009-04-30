class JoinRequestsController < ApplicationController
  authentication_filter :only => :update

  # Modify plugin create method with registration and authentication on the fly
  def create_with_authentication
    unless logged_in?
      if params[:register]
        cookies.delete :auth_token
        @user = User.new(params[:user])
        unless @user.save_with_captcha
          message = ""
          @user.errors.full_messages.each {|msg| message += msg + "  <br/>"}
          flash[:error] = message
          render :action => :new
          return
        end
      end

      self.current_agent = User.authenticate_with_login_and_password(params[:user][:email], params[:user][:password])
      unless logged_in?
        flash[:error] = "Invalid credentials"
        render :action => :new
        return
      end
    end

    create_without_authentication
  end
  alias_method_chain :create, :authentication

end
