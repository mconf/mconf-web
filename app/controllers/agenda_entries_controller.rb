class AgendaEntriesController < ApplicationController
  before_filter :space!
  before_filter :event
  
  before_filter :fill_start_and_end_time, :only => [:create, :update]
  
  # POST /agenda_entries
  # POST /agenda_entries.xml
  def create
    @agenda_entry = AgendaEntry.new(params[:agenda_entry])

    @agenda_entry.agenda = @event.agenda

    respond_to do |format|
      if @agenda_entry.save
        if params[:speakers] && params[:speakers][:name]
          unknown_users = create_performances_for_agenda_entry(Role.find_by_name("Speaker"), params[:speakers][:name])
          @agenda_entry.update_attribute(:speakers, unknown_users.join(", "))
        end
        flash[:notice] = t('agenda.entry.created')
        day = @event.day_for(@agenda_entry).to_s
        format.html { redirect_to(space_event_path(@space, @event, :show_day => day)) }
      else
        message = ""
        @agenda_entry.errors.full_messages.each {|msg| message += msg + "  <br/>"}
        flash[:error] = message
        format.html { redirect_to(space_event_path(@space, @event)) }
      end
    end
  end
  
  # GET /agenda_entries/1/edit
  def edit
    @agenda_entry = AgendaEntry.find(params[:id])
     if request.xhr?
            render "edit", :layout => false
     end
  end
  
  
  # PUT /agenda_entries/1
  # PUT /agenda_entries/1.xml
  def update
    @agenda_entry = AgendaEntry.find(params[:id])

    respond_to do |format|
      if @agenda_entry.update_attributes(params[:agenda_entry])
        if params[:speakers] && params[:speakers][:name]
          unknown_users = create_performances_for_agenda_entry(Role.find_by_name("Speaker"), params[:speakers][:name])
          @agenda_entry.update_attribute(:speakers, unknown_users.join(", "))
        end
        flash[:notice] = t('agenda.entry.updated')
        day = @event.day_for(@agenda_entry).to_s
        format.html { redirect_to(space_event_path(@space, @event, :show_day => day) ) }
      else
        flash[:notice] = t('agenda.entry.failed')
        format.html { redirect_to(space_event_path(@space, @event)) }
      end
    end
  end
  
  # DELETE /agenda_entries/1
  # DELETE /agenda_entries/1.xml
  def destroy
    @agenda_entry = AgendaEntry.find(params[:id])
    day = @event.day_for(@agenda_entry).to_s
    @agenda_entry.destroy

    respond_to do |format|
      format.html { redirect_to(space_event_path(@space, @event)) }
    end
  end
  
  private
  
  def event
    @event = Event.find(params[:event_id])
  end
  
  def space!
    @space = Space.find_by_permalink(params[:space_id])
  end
  
  
  #in the params we receive the hour and minutes (in start_time and end_time)
  #and a param called entry_day that indicates the day of the event
  #with this method we fill the real start and end time with the full time 
  def fill_start_and_end_time
    
    thedate = @event.start_date.to_date + params[:entry_day].to_i
    params[:agenda_entry][:start_time] = thedate.to_s + " " + params[:agenda_entry][:start_time]
    params[:agenda_entry][:end_time] = thedate.to_s + " " + params[:agenda_entry][:end_time]
    
  end
  
  
  #this method returns an array with the users unknown
  def create_performances_for_agenda_entry(role, array_usernames)
    unknown_users = []    
    #first we delete the old ones if there were some (this is for the update operation that creates new performances in the event)
    Performance.find(:all, :conditions => {:role_id => role, :stage_id => @agenda_entry}).each do |perf| perf.delete end
    for name in array_usernames
      #if the user is in the db we create the performance, if not it is a name that we do not know, we store it in the speakers field in db
      if user = User.find_by_login(name)
        Performance.create! :agent => user,
                            :stage => @agenda_entry,
                            :role  => role
      else
        #we do not know this user, we store the name in the array
        unknown_users << name
      end
    end
    unknown_users
  end
  
  
=begin
  # GET /agenda_entries
  # GET /agenda_entries.xml
  def index
    @agenda_entries = AgendaEntry.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @agenda_entries }
    end
  end

  # GET /agenda_entries/1
  # GET /agenda_entries/1.xml
  def show
    @agenda_entry = AgendaEntry.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @agenda_entry }
    end
  end

  # GET /agenda_entries/new
  # GET /agenda_entries/new.xml
  def new
    @agenda_entry = AgendaEntry.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @agenda_entry }
    end
  end

  # GET /agenda_entries/1/edit
  def edit
    @agenda_entry = AgendaEntry.find(params[:id])
  end

  # POST /agenda_entries
  # POST /agenda_entries.xml
  def create
    @agenda_entry = AgendaEntry.new(params[:agenda_entry])

    respond_to do |format|
      if @agenda_entry.save
        flash[:notice] = 'AgendaEntry was successfully created.'
        format.html { redirect_to(@agenda_entry) }
        format.xml  { render :xml => @agenda_entry, :status => :created, :location => @agenda_entry }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @agenda_entry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /agenda_entries/1
  # PUT /agenda_entries/1.xml
  def update
    @agenda_entry = AgendaEntry.find(params[:id])

    respond_to do |format|
      if @agenda_entry.update_attributes(params[:agenda_entry])
        flash[:notice] = 'AgendaEntry was successfully updated.'
        format.html { redirect_to(@agenda_entry) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @agenda_entry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /agenda_entries/1
  # DELETE /agenda_entries/1.xml
  def destroy
    @agenda_entry = AgendaEntry.find(params[:id])
    @agenda_entry.destroy

    respond_to do |format|
      format.html { redirect_to(agenda_entries_url) }
      format.xml  { head :ok }
    end
  end
=end
end
