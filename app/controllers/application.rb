# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base  

  before_filter :get_space 
  before_filter :get_cloud

   # Returns an Space if it is present in params or session
  def get_space    
    if params[:space_id]
        @container = @space = Space.find_by_name(params[:space_id])
        session[:space_id] = params[:space_id]
    elsif session[:space_id]
      @container = @space = Space.find_by_name(session[:space_id])
    end
    @space_thumbnail = Logotype.find(:first, :conditions => {:parent_id => @space.logotype, :thumbnail => 'space'}) if @space

    # Return @space if it exists
    @space
  end

  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_restful_auth_session_id'
  
  # Be sure to include AuthenticationSystem in Application Controller instead
  include SimpleCaptcha::ControllerHelpers 
  
  private
  
  def is_public_space
    if @space && @space.public==true
      return true
    else
      #private space, redirect to register form
      authenticated? || access_denied
    end
    #TODO esto es un cambio rapido de KIKE para que los espacios publicos sean accesibles
    #el codigo es el mismo que el metodo anterior y he comentado lo que había aquí antes
    #hay que unirlo al metodo anterior y tener una única autenticación
    #@space = Space.find(params[:container_id])
    #if @space.id == 1 || logged_in?
    #  return true
    #else
    #  redirect_to new_session_path
    #end
    
  end
  

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
    unless  evento.entry.agent == current_user || current_user.superuser==true
      user = current_user
      logger.error("ERROR: ATTEMPT TO EDIT AN EVENT THAT DOES NOT BELONG TO HIM")
      logger.error("USER WAS: " + user.login)
      flash[:notice] = "Action not allowed."     
      redirect_to root_path   
    end 
  end
  
  
  def get_cloud
    @cloud = Tag.cloud
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
  
  def get_events
    @events = if @space.id == 1
              (Event.in_container(nil).all :order => "updated_at DESC").select{|event| event.entry.public_read == true || (event.entry.container_type == 'Space' && event.entry.container_id == 1)}               
              else
              Event.in_container(@space).all :order => "updated_at DESC"
              end
  end
  
  
  
  
  #this method returns the coming 10 events
  def coming_events
    @today_events = @events.select{|e| e.start_date.to_date == Date.today && e.start_date.future? }
    @tomorrow_events = @events.select{|e| e.start_date.to_date == Date.tomorrow}
    #@week_events = @events.select{|e| e.start_date >= (Date.today + 2 ).beginning_of_day && e.start_date <= (Date.today + 7).end_of_day}    
    @coming_events = @events.select{|e| e.start_date >= (Date.today + 2 ).beginning_of_day}.first(10 - @today_events.size - @tomorrow_events.size)
  
  end
  
  
  #def next_events

    #today = Date.today
    
    #date1ok =  today.strftime("%Y%m%d")
    #s_date = Ferret::Search::SortField.new(:start_dates, :type => :float)
    #sort = Ferret::Search::Sort.new(s_date)
    #@total, @events, @query = Event.date_search_five(date1ok,:lazy => [:name, :description, :tag_list, :start_dates],  :page => (params[:page]||1), :sort=> sort)          
    #@pages = pages_for(@total)
    
    
  #end

  def get_public_entries
    @public_entries = Entry.find_all_by_container_type_and_public_read('Space',true,:order => "updated_at DESC")
  end
  
  
  
  
  def not_public_space
    
    @space = Space.find_by_name(params[:space_id])
    if @space.id == 1 && logged_in?
      flash[:notice] = "Action not allowed."     
      redirect_to root_path
    else
      return true
      
    end
    
  end
  
  
  def space_member
    if params[:space_id]
      @container = @space = Space.find_by_name(params[:space_id])
    end
    if @space.name == "Public"  || @space.public==true
      
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
