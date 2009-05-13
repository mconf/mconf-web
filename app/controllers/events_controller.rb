require 'vpim/icalendar'
require 'vpim/vevent'
require 'vpim/duration'

class EventsController < ApplicationController
  before_filter :space
  before_filter :event, :only => [ :show, :edit, :update, :destroy ]

  authorization_filter [ :read,   :content ], :space, :only => [ :index ]
  authorization_filter [ :create, :content ], :space, :only => [ :new, :create ]
  authorization_filter :read,   :event, :only => [ :show ]
  authorization_filter :update, :event, :only => [ :edit, :update ]
  authorization_filter :delete, :event, :only => [ :destroy ]

  # GET /events
  # GET /events.xml
  def index
    
    @events = (Event.in_container(@space).all :order => "start_date ASC")
      #Incoming events
      @today_events = @events.select{|e| e.start_date.to_date == Date.today && e.start_date.future?}
      @today_paginate_events = @today_events.paginate(:page => params[:page], :per_page => 10)
      @next_week_events = @events.select{|e| e.start_date.to_date >= (Date.today) && e.start_date.to_date <= (Date.today + 7) && e.start_date.future?}
      @next_week_paginate_events= @next_week_events.paginate(:page => params[:page], :per_page => 10)
      @next_month_events = @events.select{|e| e.start_date.to_date >= (Date.today) && e.start_date.to_date <= (Date.today + 30) && e.start_date.future?}
      @next_month_paginate_events = @next_month_events.paginate(:page => params[:page], :per_page => 10)
      @all_incoming_events = @events.select{|e| e.start_date.future?}
      @all_incoming_paginate_events = @all_incoming_events.paginate(:page => params[:page], :per_page => 10)
=begin      
      if params[:day] == "today"
        @incoming_title = "Today Events"
      elsif params[:day] == "next_week"
        @incoming_title = "Next Week Events"
      elsif params[:day] == "next_month"
        @incoming_title = "Next Month Events"
      else
        @incoming_title = "All incoming Events"
      end
=end
      #Past events
      @today_and_yesterday_events = @events.select{|e| (e.start_date.to_date == Date.today || e.start_date.to_date == Date.yesterday) && !e.start_date.future?}.reverse
      @today_and_yesterday_paginate_events = @today_and_yesterday_events.paginate(:page => params[:page], :per_page => 3)
      @last_week_events = @events.select{|e| e.start_date.to_date <= (Date.today) && e.start_date.to_date >= (Date.today - 7) && !e.start_date.future?}.reverse
      @last_week_paginate_events = @last_week_events.paginate(:page => params[:page], :per_page => 3)
      @last_month_events = @events.select{|e| e.start_date.to_date <= (Date.today) && e.start_date.to_date >= (Date.today - 30) && !e.start_date.future?}.reverse
      @last_month_paginate_events = @last_month_events.paginate(:page => params[:page], :per_page => 3)
      @all_past_events = @events.select{|e| !e.start_date.future?}.reverse
      @all_past_paginate_events = @all_past_events.paginate(:page => params[:page], :per_page => 3)

=begin
      if params[:day] == "yesterday"
        @past_events_events = @today_and_yesterday_events 
        @past_title = "Today Past Events and Yesterday Events"
      elsif params[:day] == "last_week"
        @past_events = @next_week_events
        @past_title = "Last Week Events"
      elsif params[:day] == "last_month"
        @past_events = @next_month_events
        @past_title = "Last Month Events"
      else
        @past_events = @all_past_events
        @past_title = "All Past Events"
      end           
      
      @past_events = @events.select{|e| !e.start_date.future?}.reverse.paginate(:page => params[:page], :per_page => 10)
=end
      #First 5 past and incoming events
      @last_past_events = @events.select{|e| !e.start_date.future?}.reverse.first(5)
      @first_incoming_events = @events.select{|e| e.start_date.future?}.first(5)  
    
    
    
    
    
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
    respond_to do |format|
	    format.html {render :layout => "conference_layout"} # show.html.erb
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
    @event.destroy

    respond_to do |format|
      format.html { redirect_to(space_events_path(@space)) }
      format.xml  { head :ok }
    end
  end
  
  
  #method to get the token to participate in a online videoconference
  def tokens
	  @token = MarteToken.create :username=>current_user.name, :role=>"admin", :room_id=>params[:id]
	  if @token.nil?
		  MarteRoom.create :name => params[:id]
		  @token = MarteToken.create :username=>current_user.name, :role=>"admin", :room_id=>params[:id]
	  end
	  if @token.nil?
		respond_to do |format|
			format.html { render :layout => false, :status => 500}
	  	end
	  else
	       respond_to do |format|
		       format.html { render :layout => false}
	       end
  	  end
  end
  
  
  private
  def future_and_past_events
    @future_events = @events.select{|e| e.start_date.future?}
    @past_events = @events.select{|e| e.start_date.past?}.sort!{|x,y| y.start_date <=> x.start_date} #Los eventos pasados van en otro inversos
  end
  
  
  def export_ical
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

  def event
    @event = Event.find(params[:id])
  end
end


