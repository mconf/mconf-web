# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base  
  # Be sure to include AuthenticationSystem in Application Controller instead
  include SimpleCaptcha::ControllerHelpers 
  include LocaleControllerModule
 
#  alias_method :rescue_action_locally, :rescue_action_in_public
 
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '29d7fe875960cb1f9357db1445e2b063'
  
  # This method calls one from the plugin, to get the Space from params or session
  def space
    current_container
  end

  # This method is the same as space, but raises error if no Space is found
  def space!
    current_container!
  end

  helper_method :space, :space!

  before_filter :not_activated_warning
  def not_activated_warning
    if authenticated? && ! current_agent.active?
      #if the account is going to be activated we only show the activaton flash not this one
      unless params[:controller] == "users" && params[:action]=="activate"
        flash[:notice] = t('user.not_activated')
      end
    end
  end
  
  before_filter :set_time_zone
  def set_time_zone
    Time.zone = current_user.timezone if current_user && current_user.is_a?(User) && current_user.timezone 
  end

  # Locale as param
  before_filter :set_vcc_locale

  def render_optional_error_file(status_code)
    if status_code == 403
      render_403
    elsif status_code == 404
      render_404
    elsif status_code == 500
      render_500
    else
      super
    end
  end
  
  def render_403
    respond_to do |type| 
      type.html { render :template => "errors/error_403", :layout => 'application', :status => 403 } 
      type.all  { render :nothing => true, :status => 403 } 
    end
    true
  end

  def render_404
    respond_to do |type| 
      type.html { render :template => "errors/error_404", :layout => 'application', :status => 404 } 
      type.all  { render :nothing => true, :status => 404 } 
    end
    true
  end
  
  def render_500
    respond_to do |type| 
      type.html { render :template => "errors/error_500", :layout => 'application', :status => 500 } 
      type.all  { render :nothing => true, :status => 500 } 
    end
    true
  end
  
  private
  
  def accept_language_header_locale
    request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first.to_sym if request.env['HTTP_ACCEPT_LANGUAGE'].present? 
  end 
    
end
