# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class EventsController < ApplicationController
  # TODO: review
  include SpamControllerModule

  layout "spaces_show"

  load_and_authorize_resource :space, :find_by => :permalink
  load_and_authorize_resource :through => :space, :find_by => :permalink

  before_filter :assign_events, :only => [:index]

  # need it to show info in the sidebar
  before_filter :webconf_room!

  after_filter :only => [:create, :update] do
    @event.new_activity params[:action], current_user unless @event.errors.any?
  end

  respond_to :html, :only => [:index, :show, :new, :create, :edit, :update]
  respond_to :atom, :only => [:index] # TODO: review

  def index
  end

  def show
    # people that confirmed whether will attend or not
    @attendees =  @event.participants.select{ |p| p.attend }
    @not_attendees = @event.participants.select{ |p| !p.attend }
  end

  def new
  end

  def create
    @event = Event.new(params[:event])
    @event.author = current_user
    @event.space = @space

    respond_to do |format|
      if @event.save
        format.html {
          flash[:success] = t('event.created')
          redirect_to space_event_path(@space, @event)
        }
      else
        format.html {
          flash[:error] = @event.errors.full_messages.join(', ')
          render :new
        }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @event.update_attributes(params[:event])
        format.html {
          flash[:success] = t('event.updated')
          redirect_to space_event_path(@space, @event)
        }
      else
        format.html {
          flash[:error] = @event.errors.full_messages.join(', ')
          render :edit
        }
      end
    end
  end

  # TODO: is this called anywhere in the app? events are disabled, not removed
  def destroy
    respond_to do |format|
      if @event.destroy
        flash[:success] = t('event.deleted')
        format.html { redirect_to(space_events_path(@space)) }
      else
        flash[:error] = @event.errors.full_messages.join(', ')
        format.html { redirect_to request.referer }
      end
    end
  end

  private

  # TODO: all the events are being filtered by software, this all can be done directly in the db
  def assign_events
    all_events = @space.events(:order => "start_date ASC")

    # events happening now
    @current_events = all_events.select{ |e| e.is_happening_now? }

    if params[:show] == 'past_events'
      @past_events = all_events.select{ |e| e.has_date? && !e.end_date.future? }
      @past_events.reverse! if params[:order_by_time] == "DESC"
      @past_events = @past_events.paginate(:page => params[:page], :per_page => 5)

    elsif params[:show] == 'upcoming_events'
      @upcoming_events = all_events.select{ |e| e.has_date? && e.start_date.future? }
      @upcoming_events = @upcoming_events.paginate(:page => params[:page], :per_page => 10)

    # the 'default' index
    else
      @last_past_events = all_events.select{ |e| e.has_date? && !e.end_date.future? }.first(3)
      @first_upcoming_events = all_events.select{ |e| e.has_date? && e.start_date.future? }.first(3)
    end
  end

end
