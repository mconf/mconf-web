require 'vpim/icalendar'
require 'vpim/vevent'
class EventsController < ApplicationController
   # Include some methods and set some default filters.
   # See documentation: CMS::Controller::Contents#included
  include CMS::Controller::Contents
  
  before_filter :authentication_required, :except => [:show, :show_timetable, :show_summary, :search, :search_events, :advanced_search_events, :search_by_title,:search_by_tag, :search_in_description, :search_by_date, :advanced_search,:title, :description, :dates, :clean]

  # Check if requesting a container
  before_filter :get_container, :only => [ :index, :show]

  # A Container is needed when posting new events
  # (see CMS::ControllerMethods#needs_container)
  before_filter :needs_container, :only => [ :new, :create ]
  
  # Included by CMS::Controller::Contents but not used here
  skip_before_filter :get_content

  #TODO: Roles
  skip_before_filter :can__create_posts__container
  skip_before_filter :can__read_posts__container
  skip_before_filter :can__update_posts__container
  skip_before_filter :can__delete_posts__container

  before_filter :no_machines, :only => [:new, :edit,:create]
  before_filter :owner_su, :only => [:edit, :update, :destroy]
   
  
  # GET /events
  # GET /events.xml
  def index
    # WTF?? This isn't RESTful!!!
    show
  end
  
  # GET /events/1
  # GET /events/1.xml
  def show

    if session[:date_start_day]
      datetime_start_day = session[:date_start_day]
    else
      datetime_start_day = Date.today      
    end
    debugger
    @cloud = Tag.cloud(:limit=> 40, :conditions => type == 'Event')
    @datetime = datetime_start_day
    event_datetimes = select_events(datetime_start_day)
    @events = []
    for datetime in event_datetimes
      for eventin in Event.find_all_by_id(datetime.event_id)
        @events << eventin unless @container && ! eventin.posted_in?(@container)
      end
    end
    @events.flatten!
    @events.uniq!
    logger.debug("eventos devueltos " + @events.size.to_s) 
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @events }
      format.js
    end
  end
  
  
  #this method update only the table of the calendar, not all the page. This is used in Ajax Calls
  def show_timetable
    if params[:date_start_day]
      datetime_start_day = Date.parse(params[:date_start_day])
      @datetime = datetime_start_day
    else
      datetime_start_day = Date.today
      @datetime = Date.today
    end
    if params[:machine]
      participant = params[:machine]
      logger.debug("la máquina ELEGIDA ES " + participant)
    else
      participant = 0 #we show all the participants
    end
    event_datetimes = select_events(datetime_start_day)
    @events = []
    for datetime in event_datetimes
      eventin = Event.find_all_by_id(datetime.event_id)
      logger.debug("eventin " + datetime.event_id.to_s)
      if eventin[0]==nil
        break
      end      
      logger.debug("EVENTO DEVUELTO por find_by_id del datetime " + eventin[0].name)
      if eventin[0].uses_participant(participant)
        logger.debug("Usa la maquina " + participant.to_s)
        @events << eventin
      end
    end
    
    @events.flatten!
    @events.uniq!
    logger.debug("TAMAÑO DEL ARRAY DEVUELTO @events.size " + @events.size.to_s)
    render(:partial => "time_table", :layout => false)
  end
  
  
  # GET /events/new
  # GET /events/new.xml
  def new    
    @event = Event.new
    @indice = "0"
    @datetime = EventDatetime.new
    if(session[:date_start_day])
      @datetime.start_date = session[:date_start_day].to_time
      @datetime.end_date = session[:date_start_day].to_time
    else
      @datetime.start_date = Time.now
      @datetime.end_date = Time.now
    end
        
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @event }
    end
  end
  
  
  # GET /events/1/edit
  def edit
    @event = Event.find(params[:id])
    @event.participants.sort!{|x,y| x.id <=> y.id}   
    @event.event_datetimes.sort!{|x,y| x.start_date <=> y.start_date}  
  end
  
  
  # POST /events
  # POST /events.xml
  def create
    @event = Event.new(params[:event])  
    indice = 0;
    param_name = 'datetime' + indice.to_s
    while params[param_name.to_sym] 
      @datetime = EventDatetime.new(params[param_name.to_sym])   
      is_valid = "is_valid_time" + indice.to_s
      if(params[is_valid.to_sym]=="true")
        @event.event_datetimes << @datetime  
      end  
      indice+=1
      param_name = 'datetime' + indice.to_s
    end
    @event.uri = @event.get_xedl_filename
    indice = 0;
    param_name = 'participant' + indice.to_s
    while params[param_name.to_sym]      
      @participant = Participant.new(params[param_name.to_sym])   
      is_valid = "is_valid_participant" + indice.to_s
      if(params[is_valid.to_sym]=="true")
        @event.participants << @participant       
      end
      indice+=1
      param_name = 'participant' + indice.to_s
    end
    
    
    respond_to do |format|
      if @event.save
        tag = params[:tag][:add_tag]    
        @event.tag_with(tag)
        
        @post = CMS::Post.create(:agent       => current_agent,
                                 :container   => @container,
                                 :content     => @event,
                                 :title       => @event.title,
                                 :description => @event.description)        
                                 
        if EventDatetime.datetime_max_length(@event.event_datetimes)
          flash[:notice] = "Event was successfully created.\r\nWarning: The interval between start and end is bigger than "+EventDatetime::MAXIMUM_LENGTH_IN_HOURS.to_s+" hours, be sure this is what you want."
        elsif EventDatetime.datetime_min_length(@event.event_datetimes)
          flash[:notice] = "Event was successfully created.\r\nWarning:the interval between start and end is smaller than "+EventDatetime::MINIMUM_LENGTH_IN_MINUTES.to_s+" minutes, be sure this is what you want."
        else
          flash[:notice] = 'Event was successfully created.'
        end
        
        format.html { redirect_to container_contents_path(:date_start_day => @event.event_datetimes[0].start_date) }
        format.xml  { render :xml => @event, :status => :created, :location => @event }
      else        
        format.html { render :action => "new" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  
  
  # PUT /events/1
  # PUT /events/1.xml
  def update
    
    begin
      Event.transaction do
        @event = Event.find(params[:id])
        @event.save_old_values
        indice = 0;
        param_name = 'datetime' + indice.to_s
        logger.debug("voy a coger los at_jobs")        
        @event.event_datetimes = []
        while params[param_name.to_sym] 
          logger.debug("param event_datetime #{param_name.to_sym}")
          @datetime = EventDatetime.new(params[param_name.to_sym])        
          if(params[:is_accomplising]==indice.to_s)
            logger.debug("datetime accomplishing")
            #the datetime is accomplising, we have the start time in a variable outside
            @datetime.start_date = Time.parse(params[:hora_inicio_acc])
          end
          is_valid = "is_valid_time" + indice.to_s
          if(params[is_valid.to_sym]=="true")        
            logger.debug("save the datetime, because is valid")
            @event.event_datetimes << @datetime
          end          
          indice+=1
          param_name = 'datetime' + indice.to_s
        end      
        indice = 0;
        param_name = 'participant' + indice.to_s   
        @event.participants = []          
        while params[param_name.to_sym]      
          @participant = Participant.new(params[param_name.to_sym])   
          is_valid = "is_valid_participant" + indice.to_s
          if(params[is_valid.to_sym]=="true")
            @event.participants << @participant 
          end
          indice+=1
          param_name = 'participant' + indice.to_s
        end          
        
        
        
        respond_to do |format|
          
          
          #@event.update_attributes(params[:event])
          logger.debug("Let's save the params for the event")
          @event.name = params[:event][:name]
          @event.password = params[:event][:password]
          @event.service = params[:event][:service]
          @event.quality = params[:event][:quality]
          @event.description = params[:event][:description]
          @event.uri = @event.get_xedl_filename
          
          logger.debug("Now we save the event")
          @event.save!
          tag = params[:tag][:add_tag]    
          @event.tag_with(tag)
          flash[:notice] = 'Event was successfully updated.<br>'
          if EventDatetime.datetime_max_length(@event.event_datetimes)
            flash[:notice] = flash[:notice] + "Warning: The interval between start and end is bigger than "+EventDatetime::MAXIMUM_LENGTH_IN_HOURS.to_s+" hours, be sure this is what you want."
          elsif EventDatetime.datetime_min_length(@event.event_datetimes)
            flash[:notice] = flash[:notice] + "Warning: The interval between start and end is smaller than "+EventDatetime::MINIMUM_LENGTH_IN_MINUTES.to_s+" minutes, be sure this is what you want."
          end
          
          
          flash[:notice] = 'Event was successfully updated.'
          format.html {redirect_to :action => 'show', :id => @event, :date_start_day=>params[:date_start_day]}
          format.xml  { head :ok }
          
        end
      end
      rescue ActiveRecord::RecordInvalid => e
      @errors = e.message  
      render :action => 'edit', :id => @event, :date_start_day=>params[:date_start_day]      
    end
  end
  
  # DELETE /events/1
  # DELETE /events/1.xml
  def destroy  
    
    @event = Event.find(params[:id])     
    #I also have to delete the at_jobs and the .xedl
    # @event.file_to_delete = @event.get_xedl_filename
    
    @datetime = @event.event_datetimes[0].start_date
    @event.destroy
    logger.debug("borrado")
    flash[:notice] = 'Event was successfully deleted.'
    
    
    respond_to do |format|
      format.html {   redirect_to :action => 'show' }
      format.xml  { head :ok }
    end
    rescue
    logger.error("Attempt to delete invalid event #{params[:id]}")
    flash[:notice] = 'Invalid event'
    redirect_to(:action => 'show')
    
  end
  
  #this method is used to create the event's summary in the right column. This is used in an Ajax Call.'
  def show_summary
    logger.debug("LLAMADA A SHOW_SUMMARY")
    
    begin
      if params[:id] && !params[:event_id]
        params[:event_id] = params[:id]   
      end
     @event = Event.find(params[:event_id])  
    
    end
    respond_to do |format|
      # format.html 
      format.js   
    end     
  end
  
  
  #This method is used when you are editing or creating a new event in order to insert a new date of the event the next week
  
  def copy_next_week
    @indice = params[:indice].to_i    
    @array_times = []
    @datetime = EventDatetime.new
    #breakpoint()
    @datetime.start_date = Time.parse(params[:date_start_day])
    @datetime.start_date = @datetime.start_date + 7*24*3600 #7 days after
    @datetime.end_date = Time.parse(params[:date_end_day])
    @datetime.end_date = @datetime.end_date + 7*24*3600 #7 days after
    @is_new = true
    logger.debug("EOEOEOEOE datetime es " + @datetime.start_date.to_s)
    render :partial => "form_datetimes_edit", :layout => false
  end 
  
  
  def remove_time    
    @indice = params[:indice]
    @element = "time"
    render(:partial => "hidden_field", :layout => false)
  end
  
  #this method is used to add a new participant in a session
  def add_participant
    @indice = params[:indice].to_i
    @indice += 1
    @array_participants = []
    render(:partial => "form_participants", :layout => false)
    logger.debug("render del partial terminado")
  end
  
  #to remove it
  def remove_participant    
    @indice = params[:indice]
    @element = "participant"
    render(:partial => "hidden_field", :layout => false)
  end
  
  def add_time
    @indice = params[:indice].to_i
    @indice += 1
    @array_times = []
    @datetime = EventDatetime.new
    @datetime.start_date = params[:date_start_day]
    @datetime.end_date = params[:date_start_day] 
    @is_new = true
    logger.debug("EOEOEOEOE datetime es " + @datetime.start_date.to_s)
    render :partial => "form_datetimes_edit", :layout => false
  end
  
  #Method to export an event in a .ics file (Icalendar RFC)
  def export_ical
    @event = Event.find(params[:id]) 
    # dates = EventDatetime.find_by_event_id(@event.id)
    urls = @event.get_urls
    url_total = ""
    for url in urls
      url_total += url.to_s + ", "
    end
    @event.event_datetimes.sort!{|x,y| x.start_date <=> y.start_date}   
    calen = Vpim::Icalendar.create2
    for datetime in @event.event_datetimes
      calen.add_event do |e|
        e.dtstart  datetime.start_date
        e.dtend  datetime.end_date
        e.description  @event.description        
        e.url url_total
        e.summary "Event Title:" + @event.name + ", Service:"+ Event.get_Service_name(@event.service)
      end 
    end 
    icsfile = calen.encode         
    # @cal_string = icsfile.to_ical
    send_data icsfile, :filename => "#{@event.name}.ics"      
    
  end
  ##METHODS THAT MAKE SEARCHES
  #only used to show the search box 
  def search
    @cloud = Tag.cloud
  end
  #method used to show the advanced search box in the ajax call
  def advanced_search
    respond_to do |format|
      # format.html 
      format.js   
    end     
  end
  #method used to show the title search box in the ajax call
  def title
    respond_to do |format|
      # format.html 
      format.js   
    end
  end
  #method used to show the description search box in the ajax call
  def description
    respond_to do |format|
      # format.html 
      format.js   
    end
  end
  
  def dates
    respond_to do |format|
      # format.html 
      format.js   
    end
  end
  #Method to clean the advanced search area
  def clean
    render :update do |page|
      page.replace_html 'advanced_search', ""
      
    end
  end
  #Method that searchs with the ferret funcionality
  def search_events 
    @cloud = Tag.cloud 
    @query = params[:query]
   
    @total, @events = Event.full_text_search(@query,:lazy => [:name, :description, :tag_list, :start_dates],  :page => (params[:page]||1))          
    @pages = pages_for(@total)
    respond_to do |format|        
      format.html     
    end
  end
  

  #metodo que devuelve los eventos que tienen un tag
  def search_by_tag    
    @cloud = Tag.cloud
    @tag = params[:tag]
    @events = Event.tagged_with(@tag)   
  end
  #Method that make the advanced search
  def advanced_search_events
    @cloud = Tag.cloud
    @query = params[:query]
    @total, @events = Event.full_text_search2(@query,:lazy => [:name, :description, :tag_list, :start_dates],  :page => (params[:page]||1))          
    @pages = pages_for(@total)
    respond_to do |format|
      format.html {render :template => "events/search_events"}
    end     
    
  end
    #Method that make the  search by title
  def search_by_title
    @cloud = Tag.cloud
    @query = params[:query]
    @total, @events = Event.title_search(@query,:lazy => [:name, :description, :tag_list, :start_dates],  :page => (params[:page]||1))          
    @pages = pages_for(@total)
    respond_to do |format|
      format.html {render :template => "events/search_events"}
    end     
    
  end
#    Method that make the search in the description of the event
  def search_in_description
    @cloud = Tag.cloud
    @query = params[:query]
    @total, @events = Event.description_search(@query,:lazy => [:name, :description, :tag_list, :start_dates],  :page => (params[:page]||1))          
    @pages = pages_for(@total)
    respond_to do |format|
      format.html {render :template => "events/search_events"}
    end     
  end
  
  
  def search_by_date

    @cloud = Tag.cloud
    @query1 = params[:query1]
    @query2 = params[:query2]
    #cambiamos el formato de las fechas,, creando un objeto de tipo date y transformandolo
   #a formato Ymd => 20081124
    date1 = Date.parse(@query1)
   date1ok =  date1.strftime("%Y%m%d")
   date2 = Date.parse(@query2)
   date2ok =  date2.strftime("%Y%m%d")
    if date1ok > date2ok
      flash[:notice] = 'The first date cannot be lower than the second one'
    render :template => "events/search"
    else
     @total, @events, @query = Event.date_search(@query1,@query2,:lazy => [:name, :description, :tag_list, :start_dates],  :page => (params[:page]||1))          
   @pages = pages_for(@total)
    respond_to do |format|
      format.html {render :template => "events/search_events"}
    end  
    end
  end
  private              
  
  #Class Method to verify the events that occurs in the date given.
  def select_events(datetime_start_day)
    datetime_end_day = datetime_start_day+1
    #first case: the event is contained in the day
    event_datetimes = EventDatetime.find(:all, :conditions=> ["start_date > ? AND end_date < ?", datetime_start_day.to_s , datetime_end_day.to_s])
    #breakpoint()
    #second case: start_date in the past and end date in the future, the event contains this day
    event_datetimes += EventDatetime.find(:all, :conditions=> ["start_date < ? AND end_date > ?", datetime_start_day.to_s , datetime_end_day.to_s])
    #third case: start_date in the past and end date in this day, the event finishes today
    event_datetimes += EventDatetime.find(:all, :conditions=> ["start_date < ? AND end_date < ? AND end_date > ?", datetime_start_day.to_s , datetime_end_day.to_s, datetime_start_day.to_s])
    #fourth case: start_date today and end date in the future, the event starts today and is longer than one day
    event_datetimes += EventDatetime.find(:all, :conditions=> ["start_date >= ? AND start_date < ? AND end_date >= ?", datetime_start_day.to_s , datetime_end_day.to_s, datetime_end_day.to_s])
    #breakpoint()  
    logger.debug("event_datetimes.size " + event_datetimes.size.to_s)
    return event_datetimes
  end
  
end
