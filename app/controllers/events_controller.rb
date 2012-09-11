# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'vpim/icalendar'
require 'vpim/vevent'
require 'vpim/duration'

class EventsController < ApplicationController
  # Include basic Resource methods
  # See documentation: ActionController::StationResources

  layout "spaces_show"
  include ActionController::StationResources
  include SpamControllerModule

  #before_filter :space!
  before_filter :event, :only => [ :show, :edit, :update, :destroy ]
  before_filter :space!
  before_filter :webconf_room!
  before_filter :adapt_new_date, :only => [:create, :update]

  load_and_authorize_resource :space
  load_and_authorize_resource :through => :space

  # GET /events
  # GET /events.xml
  def index
    # AtomPub feeds are ordered by updated_at
    if request.format == Mime::ATOM
      params[:order], params[:direction] = "updated_at", "DESC"
    end
    events

    respond_to do |format|
      format.html {
        if user_signed_in? && current_user.timezone == nil
          flash[:notice] = t('timezone.set_up', :path => edit_user_path(current_user)).html_safe
        end
        if request.xhr?
          render :layout => false;
        end
      }
      format.xml  { render :xml => @events }
      format.atom
    end
  end


  # GET /events/1
  # GET /events/1.xml
  def show
    if params[:participation_by_ajax] || params[:streaming_by_ajax]
      respond_to do |format|
        format.js
        return
      end
    end

    @assistants =  @event.participants.select{|p| p.attend == true}
    @no_assistants = @event.participants.select{|p| p.attend != true}
    @not_responding_candidates = @event.invitations.select{|e| !e.candidate.nil? && !e.processed?}
    @not_responding_emails = @event.invitations.select{|e| e.candidate.nil? && !e.processed?}
    @agenda_entry = AgendaEntry.new

    #For event repository
    @attachments,@tags = Attachment.repository_attachments(@event, params)

    @comments = @event.posts.paginate(:page => params[:page],:per_page => 5)

    respond_to do |format|
      if params[:step] == "3"
        format.html { render "_invitations" } # TODO shouldn't need to use _ at "_invitations"
      end
      format.html # show.html.erb
      format.xml{ render :xml => @event }
      format.zip{
        create_and_send_zip_file_for_scorm
      }
    end

  end

  # GET /events/new
  # GET /events/new.xml
  def new
    @event = Event.new

    respond_to do |format|
      format.html { render "new" }
      format.xml  { render :xml => @event }
    end
  end

  # GET /events/1/edit
  def edit
    #debugger
    @invited_candidates = @event.invitations.select{|e| !e.candidate.nil?}
    @invited_emails = @event.invitations.select{|e| e.candidate.nil?}
    respond_to do |format|
      format.html { render "edit" }
    end
  end

  # POST /events
  # POST /events.xml
  def create
    @event = Event.new(params[:event])
    @event.author = current_user
    @event.container = space

    respond_to do |format|
      if @event.save
        format.html {
          flash[:success] = t('event.created')
          redirect_to space_events_path(@space)
        }
        format.xml  { render :xml => @event, :status => :created, :location => @event }
      else
        format.html {
          message = ""
          @event.errors.full_messages.each {|msg| message += msg + "  <br/>"}
          flash[:error] = message
          events
          render :action => "new"
        }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.xml
  def update
    if params[:event][:description] != nil
      params[:event][:description] = params[:event][:description].gsub("</p><p>", "<br>")
      params[:event][:description] = params[:event][:description].gsub("<p>", "").gsub("</p>", "").gsub("\n", "")
    end

    respond_to do |format|
      if @event.update_attributes(params[:event])

        @event.tag_with(params[:tags]) if params[:tags] #pone las tags a la entrada asociada al evento
        flash[:success] = t('event.updated')
        format.html {
          #if (params[:event][:invited_unregistered]).blank? && (params[:event][:invited_registered]).blank?
          #  if params[:in_steps]
          #    redirect_to edit_space_event_agenda_path(space, @event, :in_steps=>params[:in_steps])
          #  else
          #    redirect_to edit_space_event_agenda_path(space, @event)
          #  end
          #else
          #  flash[:success] = t('event_invitation.sent')
          #  if params[:in_steps]
          #    if params[:event][:invited_registered]
          #      redirect_to space_event_path(@space, @event, :in_steps=>params[:in_steps], :step=>"3", :invited_registered=>true)
          #    elsif params[:event][:invited_unregistered]
          #      redirect_to space_event_path(@space, @event, :in_steps=>params[:in_steps], :step=>"3", :invited_unregistered=>true)
          #    else
          #      redirect_to space_event_path(@space, @event, :in_steps=>params[:in_steps], :step=>"3")
          #    end
          #  else
          #    if params[:event][:invited_registered]
          #      redirect_to space_event_path(@space, @event, :in_steps=>false, :step=>"3", :invited_registered=>true)
          #    elsif params[:event][:invited_unregistered]
          #      redirect_to space_event_path(@space, @event, :in_steps=>false, :step=>"3", :invited_unregistered=>true)
          #    else
          #      redirect_to space_event_path(@space, @event, :in_steps=>false, :step=>"3")
          #    end
          #  end
          #end
          redirect_to space_event_path(@space, @event)
        }
        format.xml  { head :ok }
        format.js{
          #if params[:event][:other_streaming_url]
          #  @result = params[:event][:other_streaming_url]
          #end
          if params[:event][:other_participation_url]
            @result = params[:event][:other_participation_url]
          end
          if params[:event][:description]
            @result = params[:event][:description]
            @description=true
          end
        }
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

    respond_to do |format|
      if @event.destroy
        flash[:success] = t('event.deleted')
        format.html { redirect_to(space_events_path(@space)) }
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

  private

  #method to adapt the start_date + number of days to the start_date and end_date that the event expects
  def adapt_new_date
    if params[:ndays]
      params[ :event][:end_date] = (Date.parse(params[:event][:start_date]) + params[:ndays].to_i).strftime("%d %b %Y")
    end

  end

  def future_and_past_events
    @future_events = @events.select{|e| e.start_date.future?}
    @past_events = @events.select{|e| e.start_date.past?}.sort!{|x,y| y.start_date <=> x.start_date} #Los eventos pasados van en otro inversos
  end
=begin
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
=end
  def events
      @events = (Event.in(@space).all :order => "start_date ASC")

      #Current events
      @current_events = @events.select{|e| e.is_happening_now?}

      #events without date
      @undated_events = @events.select{|e| !e.has_date?}

      #Upcoming events
      @today_events = @events.select{|e| e.has_date? && e.start_date.to_date == Date.today && e.start_date.future?}
      @today_paginate_events = @today_events.paginate(:page => params[:page], :per_page => 5)
      @next_week_events = @events.select{|e| e.has_date? && e.start_date.to_date >= (Date.today) && e.start_date.to_date <= (Date.today + 7) && e.start_date.future?}
      @next_week_paginate_events= @next_week_events.paginate(:page => params[:page], :per_page => 5)
      @next_month_events = @events.select{|e| e.has_date? && e.start_date.to_date >= (Date.today) && e.start_date.to_date <= (Date.today + 30) && e.start_date.future?}
      @next_month_paginate_events = @next_month_events.paginate(:page => params[:page], :per_page => 5)
      @all_upcoming_events = @events.select{|e| e.has_date? && e.start_date.future?}
      @all_upcoming_paginate_events = @all_upcoming_events.paginate(:page => params[:page], :per_page => 5)
      @undated_paginated_events = @undated_events.paginate(:page => params[:page], :per_page => 5)

      #Past events
      @today_and_yesterday_events = @events.select{|e| e.has_date? && ( e.end_date.to_date==Date.today || e.end_date.to_date==Date.yesterday) && !e.end_date.future?}
      @last_week_events = @events.select{|e| e.has_date? && e.start_date.to_date <= (Date.today) && e.end_date.to_date >= (Date.today - 7) && !e.end_date.future?}
      @last_month_events = @events.select{|e| e.has_date? && e.start_date.to_date <= (Date.today) && e.end_date.to_date >= (Date.today - 30) && !e.end_date.future?}
      @all_past_events = @events.select{|e| e.has_date? && !e.end_date.future?}

      if params[:order_by_time] != "ASC"
       @today_and_yesterday_events.reverse!
       @last_week_events.reverse!
       @last_month_events.reverse!
       @all_past_events.reverse!

      end
      @today_and_yesterday_paginate_events = @today_and_yesterday_events.paginate(:page => params[:page], :per_page => 5)
      @last_week_paginate_events = @last_week_events.paginate(:page => params[:page], :per_page => 5)
      @last_month_paginate_events = @last_month_events.paginate(:page => params[:page], :per_page => 5)
      @all_past_paginate_events = @all_past_events.paginate(:page => params[:page], :per_page => 5)

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
      #First 5 past and upcoming events

      @last_past_events = @all_past_events.first(3)
      @first_upcoming_events = @all_upcoming_events.first(3)
      @first_undated_events = @undated_events.first(3)

      if params[:edit]
        @event_to_edit = Event.find_by_permalink(params[:edit])
        @invited_candidates = @event_to_edit.invitations.select{|e| !e.candidate.nil?}
        @invited_emails = @event_to_edit.invitations.select{|e| e.candidate.nil?}
        #array of users of the space minus the users that has already been invited
        @users_in_space_not_invited = @space.users - @invited_candidates.map(&:candidate)
      end
  end


  def create_and_send_zip_file_for_scorm
    require 'zip/zip'
    require 'zip/zipfilesystem'
    if @video_entries.empty?
      return
    end
    #if there is no video_entries we don't generate the scorm and return

    if @event.scorm_needs_generate
      t = File.open("#{Rails.root.to_s}/public/scorm/#{@event.permalink}.zip", 'w')
      Zip::ZipOutputStream.open(t.path) do |zos|
        @event.generate_scorm_manifest_in_zip(zos)

        @video_entries.each do |entry|
          @render = render_to_string :partial => "agenda_entries/scorm_show", :locals => {:entry=>entry}
          #File.open("#{Rails.root.to_s}/public/scorm/#{@event.permalink}/#{Event.remove_accents(entry.title)}.html", "w") { |f| f.write @render }
          zos.put_next_entry("#{Event.remove_accents(entry.title)}.html")
          zos.print @render
          entry.attachments.each do |file|
            zos.put_next_entry(Event.remove_accents(file.filename))
            zos.print IO.read(file.full_filename)
          end
        end
        #in the end we include the css for the html files and the images
        zos.put_next_entry("scorm.css")
        zos.print IO.read("#{Rails.root.to_s}/app/assets/stylesheets/application/old/scorm.css")

        zos.put_next_entry("mconf_logo_small.png")
        zos.print IO.read("#{PathHelpers.images_full_path}/mconf_logo_small.png")

        zos.put_next_entry("vcc-logo-transparente1.png")
        zos.print IO.read("#{PathHelpers.images_full_path}/vcc-logo-transparente1.png")

      end
      t.close
    end

    send_file "#{Rails.root.to_s}/public/scorm/#{@event.permalink}.zip", :type => 'application/zip', :disposition => 'attachment', :filename => "#{@event.permalink}.zip"
  end
end
