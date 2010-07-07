# Copyright 2008-2010 Universidad Politécnica de Madrid and Agora Systems S.A.
#
# This file is part of VCC (Virtual Conference Center).
#
# VCC is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# VCC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with VCC.  If not, see <http://www.gnu.org/licenses/>.

class AgendaEntriesController < ApplicationController
  include ActionController::StationResources

  before_filter :space!
  before_filter :event
  
  
  #before_filter :fill_start_and_end_time, :only => [:create, :update]

  authorization_filter :create, :agenda_entry, :only => [ :new, :create ]
  authorization_filter :read,   :agenda_entry, :only => [ :show, :index ]
  authorization_filter :update, :agenda_entry, :only => [ :edit, :update ]
  authorization_filter :delete, :agenda_entry, :only => [ :destroy ]

  
  #authorization_filter :create, :agenda_entry, :only => [ :new, :create ]
  #authorization_filter :update, :agenda_entry, :only => [ :edit, :update ]
  #authorization_filter :delete, :agenda_entry, :only => [ :destroy ]
  

  def index
    raise ActiveRecord::RecordNotFound    
  end

#  #GET /agenda_entries
#  #GET /agenda_entries.xml
#  #returns the agenda_entries for the days 2 to end by ajax
#  def index
#    @days = (0..@event.days-1).to_a
#    if @event.days > 1   
#      unless params[:page_shown]
#        params[:page_shown]="0"
#      end
#      #the agenda has shown params[:page_shown], let's remove it from the pages to be shown     
#      @days.delete(params[:page_shown])
#    end
#    respond_to do |format|
#      if request.xhr?
#        format.js
#      else
#        format.html { redirect_to [ @event.space, @event ] }
#      end
#    end 
#  end

  # GET /agenda_entries/1
  # GET /agenda_entries/1.xml
  def show
    @agenda_entry = AgendaEntry.find(params[:id])

    respond_to do |format|
      format.js
      format.html # show.html.erb
      format.xml  { render :xml => @agenda_entry }
    end
  end
  
  
  #this method is called from event_to_scorm lib to generate an html web page with this video entry and documents
  def scorm_show
    #@entry has been defined in event_to_scorm lib  
    respond_to do |format|
      format.html
    end    
  end
  
  
  # GET /agenda_entries/new
  # GET /agenda_entries/new.xml
  def new
     @agenda_entry = AgendaEntry.new
     @day=params[:day]
     

  end
  
  # POST /agenda_entries
  # POST /agenda_entries.xml
  def create
    @agenda_entry = AgendaEntry.new(params[:agenda_entry])

    @agenda_entry.agenda = @event.agenda
    @agenda_entry.author = current_user
    
    respond_to do |format|
      if @agenda_entry.save
        @event.reload  #reload the event in case the start date or end date has changed
        format.html {redirect_to(space_event_path(@space, @event, :show_agenda=>true, :show_day=>@agenda_entry.event_day, :edit_entry => @agenda_entry.id, :anchor=>"edit_entry_anchor" )) }
      else    
        flash[:notice] = t('agenda.entry.failed')
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
    @day=@agenda_entry.event_day
  end
  
  
  # PUT /agenda_entries/1
  # PUT /agenda_entries/1.xml
  def update
    @agenda_entry = AgendaEntry.find(params[:id])
    @agenda_entry.author = current_user
    
    respond_to do |format|
      if @agenda_entry.update_attributes(params[:agenda_entry])
        #first we delete the old performances if there were some (this is for the update operation that creates new performances in the event)
        Performance.find(:all, :conditions => {:role_id => Role.find_by_name("Speaker"), :stage_id => @agenda_entry}).each do |perf| perf.delete end
        if params[:speakers] && params[:speakers][:name]
          unknown_users = create_performances_for_agenda_entry(Role.find_by_name("Speaker"), params[:speakers][:name])
          @agenda_entry.update_attribute(:speakers, unknown_users.join(", "))
        end
        flash[:notice] = t('agenda.entry.updated')
        day = @agenda_entry.event_day
        format.html { redirect_to(space_event_path(@space, @event, :show_agenda=>true, :show_day => day) ) }
      else
        message = ""
        @agenda_entry.errors.full_messages.each {|msg| message += msg + "  <br/>"}
        flash[:error] = message
        format.html { redirect_to(space_event_path(@space, @event)) }
      end
    end
  end
  
  # DELETE /agenda_entries/1
  # DELETE /agenda_entries/1.xml
  def destroy
    @agenda_entry = AgendaEntry.find(params[:id])
    day = @agenda_entry.event_day
    agenda = @agenda_entry.agenda
    respond_to do |format|
      if @agenda_entry.destroy
        flash[:notice] = t('agenda.entry.delete')
        if agenda.contents_for_day(day).blank?
          format.html { redirect_to(space_event_path(@space, @event, :show_agenda=>true, :show_day => 1)) }
        else
          format.html { redirect_to(space_event_path(@space, @event, :show_agenda=>true, :show_day => day)) }
        end
        format.xml  { head :ok }
      else
        message = ""
        @agenda_entry.errors.full_messages.each {|msg| message += msg + "  <br/>"}
        flash[:error] = message
        format.html { redirect_to(space_event_path(@space, @event)) }
      end
    end  
    
  end
  
  private
  
  def event
    @event = Event.find_by_permalink(params[:event_id]) || raise(ActiveRecord::RecordNotFound)
  end
  
  #in the params we receive the hour and minutes (in start_time and end_time)
  #and a param called entry_day that indicates the day of the event
  #with this method we fill the real start and end time with the full time 
  def fill_start_and_end_time 
      thedate = @event.start_date.to_date + params[:entry_day].to_i      
      params[:agenda_entry][:start_time] = thedate + params[:agenda_entry]["start_time(4i)"].to_i.hour + params[:agenda_entry]["start_time(5i)"].to_i.min
      params[:agenda_entry][:end_time] = thedate + params[:agenda_entry]["end_time(4i)"].to_i.hour + params[:agenda_entry]["end_time(5i)"].to_i.min

  end
  
  
  #this method returns an array with the users unknown
  def create_performances_for_agenda_entry(role, array_usernames)
    unknown_users = []
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
  
  # Redefining path_container method from Station as the container (Agenda) does not have
  # its ID in the path because Event has_one Agenda instead of has_many
  def path_container(options = {})
    if (options[:type]).nil? || (options[:type] == Agenda)
      return event.agenda
    else
      super
    end
  end
end
