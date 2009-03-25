require 'vpim/icalendar'
require 'vpim/vevent'
require 'vpim/duration'

class EventsController < ApplicationController
  
   before_filter :space
  # GET /events
  # GET /events.xml
  def index
    
    @events = (Event.in_container(@space).all :order => "updated_at DESC")
    
    if params[:show] == "lastest_events"
      @latest_events = @events.select{|e| e.start_date.future?}.paginate(:page => params[:page], :per_page => 10)
    elsif params[:show] == "coming_events" 
      @today_events = @events.select{|e| e.start_date.to_date == Date.today && e.start_date.future? }
      @next_week_events = @events.select{|e| e.start_date >= (Date.today).beginning_of_day && e.start_date <= (Date.today + 7).end_of_day && e.start_date.future?}
      @next_month_events = @events.select{|e| e.start_date >= (Date.today).beginning_of_day && e.start_date <= (Date.today + 30).end_of_day && e.start_date.future?}
      @all_coming_events = @events.select{|e| e.start_date.future?}.sort!{|x,y| x.start_date <=> y.start_date}
      if params[:day] == "today"
        @coming_events = @today_events 
        @title = "Today Events"
      elsif params[:day] == "next_week"
        @coming_events = @next_week_events
        @title = "Next Week Events"
      elsif params[:day] == "next_month"
        @coming_events = @next_month_events
        @title = "Next Month Events"
      else
        @coming_events = @all_coming_events
        @title = "All Coming Events"
      end
        @coming_events = @coming_events.paginate(:page => params[:page], :per_page => 10)
      #@tomorrow_events = @events.select{|e| e.start_date.to_date == Date.tomorrow}

    elsif params[:show] == "past_events"
      @past_events = @events.select{|e| !e.start_date.future?}.paginate(:page => params[:page], :per_page => 10)
    else
      @latest_events = @events.first(5)
      @incoming_events = @events.select{|e| e.start_date.future?}.sort!{|x,y| x.start_date <=> y.start_date}.first(5)  
    end
    
    
    
    
    
=begin
    Event.in_container(@space).at_date(params[:date_start_date]).paginate(params[:paginate])
    
    if params[:date_start_day]
       @start_day = Date.parse(params[:date_start_day])
       @events = if @space.id == 1
              (Event.in_container(nil).all :order => "updated_at DESC").select{|event| (event.public_read == true || (event.container_type == 'Space' && event.container_id == 1)) && event.start_date.to_date == @start_day}               
              else
              (Event.in_container(@space).all :order => "updated_at DESC").select{|event| event.start_date.to_date == @start_day}
              end
    else
      @start_day = Date.today
      get_events #obtain the space events
      if params[:view_all]
        future_and_past_events
      else
        coming_events  
      end
    end
=end
    
    #@events = @events_all - @today_events - @tomorrow_events - @week_events
    respond_to do |format|
      format.html { }
    #format.html # index.html.erb
      format.xml  { render :xml => @events }
    end
  end

  # GET /events/1
  # GET /events/1.xml
  def show
    session[:current_tab] = "Events"
    @event = Event.find(params[:id])
    Mime::Type.register "ical", :ical
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @event }
      format.js 
      format.ical {export_ical}
    end
  end

  # GET /events/new
  # GET /events/new.xml
  def new
    @event = Event.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @event }
    end
  end

  # GET /events/1/edit
  def edit
    @event = Event.find(params[:id])
  end

  # POST /events
  # POST /events.xml
  def create
    @event = Event.new(params[:event])
    @event.author = current_agent
    @event.container = @container
    respond_to do |format|
      if @event.save
        #@event.tag_with(params[:tags]) if params[:tags] #pone las tags a la entrada asociada al evento
        flash[:success] = 'Event was successfully created.'
        format.html {redirect_to request.referer }
        format.xml  { render :xml => @event, :status => :created, :location => @event }
      else
        format.html {  
        message = ""
        @event.errors.full_messages.each {|msg| message += msg + "  <br/>"}
        flash[:error] = message
        redirect_to request.referer
        }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.xml
  def update
    @event = Event.find(params[:id])

    respond_to do |format|
      if @event.update_attributes(params[:event])
        @event.tag_with(params[:tags]) if params[:tags] #pone las tags a la entrada asociada al evento
        flash[:success] = 'Event was successfully updated.'
        format.html {redirect_to space_events_path(@space) }
        format.xml  { head :ok }
      else
        format.html { message = ""
        @event.errors.full_messages.each {|msg| message += msg + "  <br/>"}
        flash[:error] = message
        redirect_to request.referer }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.xml
  def destroy
    @event = Event.find(params[:id])
    @event.destroy

    respond_to do |format|
      format.html { redirect_to(space_events_path(@space)) }
      format.xml  { head :ok }
    end
  end
  
  
  private
  def future_and_past_events
    @future_events = @events.select{|e| e.start_date.future?}
    @past_events = @events.select{|e| e.start_date.past?}.sort!{|x,y| y.start_date <=> x.start_date} #Los eventos pasados van en otro inversos
  end
  
  def export_ical
      @event = Event.find(params[:id]) 
      calen = Vpim::Icalendar.create2
      calen.add_event do |e|
        e.dtstart @event.start_date
        e.dtend   @event.end_date
        e.description @event.description
        e.summary   @event.name
        e.set_text('LOCATION', @event.place)
      end
      icsfile = calen.encode         
      send_data icsfile, :filename => "#{@event.name}.ics"      
      
  end
end


