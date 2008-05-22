# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base  
  
   before_filter :set_locale
#Method used in the globalize plugin to set base language
  def set_locale
    accept_locales = LOCALES.keys # change this line as needed, must be an array of strings
    cookies[:locale] = params[:locale] if accept_locales.include?(params[:locale])
    Locale.set(cookies[:locale] || (request.env["HTTP_ACCEPT_LANGUAGE"] || "").scan(/[^,;]+/).find{|l| accept_locales.include?(l)})
  end
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_restful_auth_session_id'
  
  # Be sure to include AuthenticationSystem in Application Controller instead
  include CMS::Controller::Authentication
  include SimpleCaptcha::ControllerHelpers 
  
  private
   #Method that checks if the current user have machines assigned (Filter)
  def no_machines
    if current_user.machines.empty?
      user = User.find_by_id(current_user.id)
      logger.error("ERROR: ATTEMPT TO CREATE A NEW EVENT WITHOUT RESOURCES ASSIGNED")
      logger.error("USER WAS: " + user.login)
      flash[:notice] = "You have no resources assigned so you can't create new events or edit existing ones."          
      redirect_to(:controller => "events", :action => "show")      
      end
    end
    
    
     #Method that checks if the current user is the owner of the event(the person who created it)
# or it checks  if the user is an administrator (Filter)
   def owner_su
    
       evento = Event.find_by_id(params[:id])
     unless  current_user.events.include?(evento) || current_user.superuser==true
      user = current_user
      logger.error("ERROR: ATTEMPT TO EDIT AN EVENT THAT DOES NOT BELONG TO HIM")
      logger.error("USER WAS: " + user.login)
      flash[:notice] = "Action not allowed."     
      redirect_to(:controller => "events", :action => "show")     
    end 
  end
  
  def unique_profile
    profile = Profile.find_by_users_id(current_user.id)
    unless profile == nil
      user = current_user
      logger.error("ERROR: ATTEMPT TO EDIT AN EVENT THAT DOES NOT BELONG TO HIM")
      logger.error("USER WAS: " + user.login)
      flash[:notice] = "You have already a profile."     
      redirect_to(:controller => "profiles", :action => "show", :id=> profile.id)  
    end
  end
  def user_profile_owner
    profile = Profile.find_by_users_id(params[:id])
    unless profile != nil && profile.users_id == current_user.id
      user = current_user
      logger.error("ERROR: ATTEMPT TO EDIT AN EVENT THAT DOES NOT BELONG TO HIM")
      logger.error("USER WAS: " + user.login)
      flash[:notice] = "Action not allowed."     
      redirect_to(:controller => "events", :action => "show")  
    end
  end
  def profile_owner

    profile = Profile.find_by_id(params[:id])
    unless profile != nil && profile.users_id == current_user.id
      user = current_user
      logger.error("ERROR: ATTEMPT TO EDIT AN EVENT THAT DOES NOT BELONG TO HIM")
      logger.error("USER WAS: " + user.login)
      flash[:notice] = "Action not allowed."     
      redirect_to(:controller => "events", :action => "show")  
    end
  end
  def user_is_admin
    unless current_user.superuser
      logger.error("ERROR: ATTEMPT TO MANAGE MACHINES AND HE IS NOT SUPERUSER")
      logger.error("USER WAS: " + current_user.login)
      flash[:notice] = "Action not allowed."     
      redirect_to(:controller => "events", :action => "show")     
    end
  end
  #Method that create a Paginator for the events searches
  def pages_for(size, options = {})
    default_options = {:per_page => 10}
    options = default_options.merge options
    pages = Paginator.new self, size, options[:per_page], (params[:page]||1)
   return pages
end
end
