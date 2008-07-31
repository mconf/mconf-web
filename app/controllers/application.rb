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
      redirect_to root_path      
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
      redirect_to root_path   
    end 
  end
  
  def unique_profile
    profile = Profile.find_by_user_id(current_user.id)
    unless profile == nil
      user = current_user
      logger.error("ERROR: ATTEMPT TO EDIT AN EVENT THAT DOES NOT BELONG TO HIM")
      logger.error("USER WAS: " + user.login)
      flash[:notice] = "You have already a profile."     
      redirect_to(:controller => "profiles", :action => "show")  
    end
  end
  
  def get_cloud
    @cloud = Tag.cloud
  end
  def profile_owner
    
    @user = User.find_by_id(params[:user_id])
    
    
    unless  @user.id == current_user.id || current_user.superuser
      user = current_user
      
      flash[:notice] = "Action not allowed."     
      redirect_to root_path
    end
  end
  def user_is_admin
    unless current_user.superuser
      logger.error("ERROR: ATTEMPT TO MANAGE MACHINES AND HE IS NOT SUPERUSER")
      logger.error("USER WAS: " + current_user.login)
      flash[:notice] = "Action not allowed."     
      redirect_to root_path
    end
  end
  #Method that create a Paginator for the events searches
  def pages_for(size, options = {})
    default_options = {:per_page => 10}
    options = default_options.merge options
    pages = Paginator.new self, size, options[:per_page], (params[:page]||1)
    return pages
  end
  #this method returns the coming 5 events
  def next_events
    
    
    today = Date.today
    
    date1ok =  today.strftime("%Y%m%d")
    s_date = Ferret::Search::SortField.new(:start_dates, :type => :float)
    sort = Ferret::Search::Sort.new(s_date)
    @total, @events, @query = Event.date_search_five(date1ok,:lazy => [:name, :description, :tag_list, :start_dates],  :page => (params[:page]||1), :sort=> sort)          
    @pages = pages_for(@total)
    
    
  end
  
  def get_public_posts
    @public_posts = CMS::Post.find_all_by_container_type_and_public_read('Space',true)
  end
  
  def get_space
    if params[:container_type]=="posts"
      @space = CMS::Post.find(params[:container_id]).container
      get_container
      return
    end
    if params[:space_id]
      params[:container_id] = params[:space_id]
    end
    if params[:container_id]==nil && params[:id]!=nil
      #this case is /spaces/1 ... /spaces/:id
      params[:container_id] = params[:id]
    end
    @space = Space.find(params[:container_id])
    get_container
  end
  
  def is_public_space
   
    @space = Space.find(params[:container_id])
    if @space.id == 1 || logged_in?
      return true
    else
      redirect_to new_session_path
    end
    
  end
  
  def not_public_space
    
    @space = Space.find(params[:container_id])
    if @space.id == 1 && logged_in?
      flash[:notice] = "Action not allowed."     
      redirect_to root_path
    else
      return true
      
    end
    
  end
  def remember_tab_and_space
    #save the current space, because this routes are /roles /roles/new and so on
    if params[:container_id]
      session[:current_space] = params[:container_id]
    end
    @space = Space.find(session[:current_space])
  end
  def space_member
    
    @space = Space.find(params[:container_id])
    if @space.id == 1  || @space.public==true
      
      return true
    elsif logged_in? && current_user.superuser
      return true
    else
      
      unless @space.actors.include?(current_user)
        flash[:notice] = "Action not allowed."     
        redirect_to root_path
        
      end
    end
  end
end
