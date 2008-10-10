require 'openid'
require 'openid/extensions/sreg'

# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  # Don't render plugin layout, use application instead
  layout 'application'

  # render new.rhtml
  def new
    if logged_in?
      flash[:error] = "You are already logged in"
       
      redirect_to root_path
    end
  end

  private

  def after_create_path
    spaces_path
  end

  def after_destroy_path
    spaces_path
  end
 
  def get_space
    @container = @space = Space.find_by_name("Public")
  end

end
