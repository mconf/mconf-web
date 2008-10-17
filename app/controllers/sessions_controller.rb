# This controller handles the login/logout function of the site.  
#
# See vendor/plugins/cmsplugin/app/controllers/sessions_controller for the rest of the methods
class SessionsController < ApplicationController
  # Don't render plugin layout, use application instead
  layout 'application'

  # render new.rhtml
  def new
    if logged_in?
      flash[:error] = "You are already logged in".t
      redirect_to root_path
      return
    end

    # See CMS::Cotroller::Sessions#authentication_methods_chain 
    authentication_methods_chain(:new)
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
