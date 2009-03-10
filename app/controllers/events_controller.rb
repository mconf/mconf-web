require 'vpim/icalendar'
require 'vpim/vevent'
require 'vpim/duration'


class EventsController < ApplicationController
  # GET /events
  # GET /events.xml
  def index
    session[:current_tab] = "Events"
    session[:current_sub_tab] = ""

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
    #@events_all = Event.find(:all)
    #@events = @events_all - @today_events - @tomorrow_events - @week_events
    respond_to do |format|
      format.html { if params[:date_start_day]
        render :partial => "day_events", :layout => true
      end}
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
        @event.tag_with(params[:tags]) if params[:tags] #pone las tags a la entrada asociada al evento
        flash[:notice] = 'Event was successfully created.'
        format.html { redirect_to(space_event_path(@space,@event)) }
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
    @event = Event.find(params[:id])

    respond_to do |format|
      if @event.update_attributes(params[:event])
        @event.tag_with(params[:tags]) if params[:tags] #pone las tags a la entrada asociada al evento
        flash[:notice] = 'Event was successfully updated.'
        format.html {redirect_to(space_event_path(@space,@event)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
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
      format.html { redirect_to(events_url) }
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


