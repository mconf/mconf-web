require 'vpim/icalendar'
require 'vpim/vevent'
class EventsController < ApplicationController
  # Include some methods and filters.
  include CMS::Controller::Contents
  
  before_filter :authentication_required, :except => [:index,:show, :search, :search_events, :advanced_search_events, :search_by_title,:search_by_tag, :search_in_description, :search_by_date, :advanced_search,:title, :description, :dates, :clean]
  
  before_filter :get_cloud

  
  # A Container is needed when posting new events
  # (see CMS::ControllerMethods#needs_container)
  before_filter :needs_container, :only => [ :new, :create ]
  before_filter :get_space
  #TODO: Authorization
  before_filter :is_public_space, :only=>[:index]
  before_filter :space_member, :except => [ :search, :search_events, :advanced_search_events, :search_by_title,:search_by_tag, :search_in_description, :search_by_date, :advanced_search,:title, :description, :dates, :clean]
  #before_filter :no_machines, :only => [:new, :edit,:create]
  before_filter :owner_su, :only => [:edit, :update, :destroy]
  
  skip_before_filter :get_content, :only => [:new, :add_time, :create, :index, :show, :copy_next_week, :remove_time]
  
  
  # GET /events
  # GET /events.xml
  
  def index
    session[:current_tab] = "Events"
    session[:current_sub_tab] = ""
    @datetime = Date.today
    next_events
    #@events = @space.events
    
    if params[:date_start_day]
      session[:current_sub_tab] = "Show Calendar"
      datetime_start_day = Date.parse(params[:date_start_day])
      #elsif  session[:date_start_day]
      #  datetime_start_day = Date.parse(session[:date_start_day])       
      
      
      @datetime = datetime_start_day
      participant = 0 #we show all the participants, comes from SIR 1.0, "filter view"
      event_datetimes = select_events(datetime_start_day)
      @events = []
      for dat in event_datetimes
        for eventin in Event.find_all_by_id(dat.event_id)
          @events << eventin unless @container && ! eventin.posted_in?(@container)
        end
      end
      @events.flatten!
      @events.uniq!
      logger.debug("eventos devueltos " + @events.size.to_s) 
      @events
 
end

     respond_to do |format|
        format.html { if params[:date_start_day]
        render :partial => "show_calendar", :layout => true
        end}
        format.xml  { render :xml => @events }
        format.atom
        format.js 
      end
  end
  
  
  # GET /events/1
  # GET /events/1.xml
  
  def show
    session[:current_tab] = "Events" 
    #this part is used to create the event's summary in the left column. This is used in an Ajax Call.'
    if params[:show_summary]
      logger.debug("LLAMADA A SHOW_SUMMARY")   
      begin
        if params[:id] && !params[:event_id]
          params[:event_id] = params[:id]   
        end
        begin
          @event = Event.find(params[:event_id]) 
          @show_summary = true
        rescue
        end
      end
    else
      @datetime = Date.today
      @event = Event.find(params[:id])
      @event.event_datetimes.sort!{|x,y| x.start_date <=> y.start_date}  
    end
    
    Mime::Type.register "ical", :ical
    
    respond_to do |format|
      format.html 
      format.xml  { render :xml => @event.to_xml(:include => :event_datetimes) }
      format.js
      format.ical { export_ical }
    end
  end
  
  # GET /events/new
  # GET /events/new.xml
  
  def new    
    @event = Event.new
    @indice = "0"   
    session[:current_sub_tab] = "New Event"
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
    if params[:format] = "atom"
      params[:event] = params[:feed][:entry]
            params[:start_date0] = params[:event][:datetime][:start_date0]
            params[:end_date0] = params[:event][:datetime][:end_date0]
            params[:tag] = params[:event][:tag]
      params[:event].delete :datetime
      params[:event].delete :tag

    end
    
    debugger
    @event = Event.new(params[:event])  
    indice = 0;
    param_start_date = 'start_date' + indice.to_s
    param_end_date = 'end_date' + indice.to_s
    is_valid = "is_valid_time" + indice.to_s
    while params[param_start_date.to_sym] 
      logger.debug("New datetime for this event: " + indice.to_s)
       @datetime = EventDatetime.new(:start_date=>params[param_start_date.to_sym], :end_date=>params[param_end_date.to_sym]) 
       #·   if(params[is_valid.to_sym]=="true")
        @event.event_datetimes << @datetime  
  #    end  
      indice+=1
      param_start_date = 'start_date' + indice.to_s
      param_end_date = 'end_date' + indice.to_s
      is_valid = "is_valid_time" + indice.to_s
    end
    
    @event.uri = @event.get_xedl_filename    
    
    array_participants = Event.configure_participants_for_sites(current_user, @event.event_datetimes, params[:event][:all_participants_sites])
    
    if array_participants==nil
      flash[:notice] = "You can't create events bigger than " + (current_user.machines.length*Participant::NUMBER_OF_SITES_PER_PARTICIPANT).to_s + " sites connected."
      respond_to do |format|
        format.html {render :action => "new"}
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }        
      end
      return
    end
    
    if array_participants.length < (params[:event][:all_participants_sites].to_i/Participant::NUMBER_OF_SITES_PER_PARTICIPANT).ceil
      #there are no enough free machines
      flash[:notice] = "There are no enough resources free to create new events at this time. You can ask for more to the administrator."
      respond_to do |format|
        format.html {render :action => "new"}
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }        
      end
      return
    end
    @event.participants = array_participants
    
    respond_to do |format|
      if @event.save
        tag = params[:tag][:add_tag]    
        @event.tag_with(tag)
        
        @entry = Entry.create(:agent       => current_agent,
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
        
        format.html { redirect_to space_events_path(@container, :date_start_day => @event.event_datetimes[0].start_date) }

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
        param_name_start_date = 'start_date' + indice.to_s
        param_name_end_date = 'end_date'+indice.to_s
        start_date = params[param_name_start_date.to_sym]
        end_date =  params[param_name_end_date.to_sym]
        logger.debug("voy a coger los at_jobs")        
        @event.event_datetimes = []
        while params[param_name_start_date.to_sym] && params[param_name_start_date.to_sym]!=""
          if(Event.validate_format_datetime(start_date) && Event.validate_format_datetime(end_date))
            if(Time.parse(end_date)<Time.parse(start_date))
              flash[:notice] = "The "+ Event.get_ordinal(indice+1) +" datetime is incorrect, the end date is before the start date"  
              respond_to do |format|
                format.html {render :action => "edit"}
                format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }     
              end
              return
            end
            @datetime = EventDatetime.new :start_date => start_date, :end_date => end_date
            is_valid = "is_valid_time" + indice.to_s
            if(params[is_valid.to_sym]=="true")        
              logger.debug("save the datetime, because is valid")
              @event.event_datetimes << @datetime
            end
          else
            flash[:notice] = "The "+ Event.get_ordinal(indice+1) +" datetime format is incorrect."  
            respond_to do |format|
              format.html {render :action => "edit"}
              format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }     
            end
            return
          end                  
          indice+=1
          param_name_start_date = 'start_date' + indice.to_s
          param_name_end_date = 'end_date'+indice.to_s 
          start_date = params[param_name_start_date.to_sym]
          end_date =  params[param_name_end_date.to_sym]
        end
        indice = 0;
        param_name = 'participant' + indice.to_s   
        @event.participants = []          
        
        array_participants = Event.configure_participants_for_sites(current_user, @event.event_datetimes, params[:event][:all_participants_sites])
        if array_participants==nil
          flash[:notice] = "You can't create events bigger than " + (current_user.machines.length*Participant::NUMBER_OF_SITES_PER_PARTICIPANT).to_s + " sites connected."
          respond_to do |format|
            format.html {render :action => "edit"}
            format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }        
          end
          return
        end
        if array_participants.length < (params[:event][:all_participants_sites].to_i/Participant::NUMBER_OF_SITES_PER_PARTICIPANT).ceil
          #there are no enough free machines
          flash[:notice] = "There are no enough resources free to create new events at this time. You can ask for more to the administrator."
          respond_to do |format|
            format.html {render :action => "edit"}
            format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }        
          end
          return
        end
        @event.participants = array_participants
        
        
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
      format.html# {   redirect_to :action => 'show' }
      format.xml  { head :ok }
    end
  rescue
    logger.error("Attempt to delete invalid event #{params[:id]}")
    flash[:notice] = 'Invalid event'
    redirect_to(:action => 'index')
    
  end
  
  
  
  
  #This method is used when you are editing or creating a new event in order to insert a new date of the event the next week
  
  def copy_next_week
    @indice = params[:indice].to_i    
    @array_times = []
    @datetime = EventDatetime.new
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
  
  
  def add_time
    @indice = params[:indice].to_i
    @indice += 1
    @array_times = []
    #esto era para inicializar antiguamente, ahora aparece vacío
    #@datetime = EventDatetime.new
    #@datetime.start_date = params[:date_start_day]
    #@datetime.end_date = params[:date_start_day] 
    @is_new = true
    render :partial => "form_datetimes_edit", :layout => false
  end
  
=begin  
TODO métodos a eliminar por pasar todas las busquedas al SearchController  
    ##METHODS THAT MAKE SEARCHES
  #only used to show the search box 
  def search
    
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
  
  
  #method used to show the dates search boxes in the ajax call
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
  
  
  #method to clean the div in where an event information is shown
  def clean_show
    render :update do |page|
      page.replace_html 'show_event', ""
      
    end
  end
  
  
  #Method that searchs events in the container.
  #RAFA ESTE METODO CON INDEX
  def search_events 
    #events_path(:query => "bla") #=> /events?query=bla    
    @query = params[:query]
    @even = Entry.find_all_by_container_id_and_content_type(@container.id, "Event")
    @total, @results = Event.full_text_search(@query,  :page => (params[:page]||1))          
    @pages = pages_for(@total)
    @partials = []
    @events = []  
    if @results != nil
      @results.collect { |result|
        event = Entry.find_by_content_type_and_content_id("Event", result.id)
        if @even.include?(event)
          @partials << event
        end
      }
    end
    if @partials != nil
      @partials.collect { |a|
        even = Event.find(a.content_id)
        @events << even
      }      
    end    
    respond_to do |format|        
      format.html     
    end
  end
 
  
  
  #Method that make the advanced search
  def advanced_search_events
    
    @query = params[:query]
    @total, @events = Event.full_text_search2(@query,  :page => (params[:page]||1))          
    @pages = pages_for(@total)
    respond_to do |format|
      format.html {render :template => "events/search_events"}
    end     
    
  end
  
  
  #Method that make the  search by title
  def search_by_title
    
    @query = params[:query]
    @total, @events = Event.title_search(@query,  :page => (params[:page]||1))          
    @pages = pages_for(@total)
    respond_to do |format|
      format.html {render :template => "events/search_events"}
    end     
    
  end
  
  
  #    Method that make the search in the description of the event
  def search_in_description
    
    @query = params[:query]
    @total, @events = Event.description_search(@query,  :page => (params[:page]||1))          
    @pages = pages_for(@total)
    respond_to do |format|
      format.html {render :template => "events/search_events"}
    end     
  end
  
  
  #this method search an event between two dates
  def search_by_date
    
    
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
      @total, @events, @query = Event.date_search(@query1,@query2,  :page => (params[:page]||1))          
      @pages = pages_for(@total)
      respond_to do |format|
        format.html {render :template => "events/search_events"}
      end  
    end
  end

  
    #metodo que devuelve los eventos que tienen un tag, y los ususarios y los entries
  def search_by_tag    
    
    @tag = params[:tag]
    
    @events = Event.tagged_with(@tag) 
    @users = User.tagged_with(@tag) 
    
    @entries = Entry.tagged_with(@tag)
    
  end
=end  
  private        
  
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
