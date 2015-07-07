# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class SpaceEventsController < ApplicationController

  layout "spaces_show"

  # return 404 for all routes if the events are disable
  before_filter do
    unless Mconf::Modules.mod_enabled?('events')
      raise ActionController::RoutingError.new('Not Found')
    end
  end

  load_and_authorize_resource :space, :find_by => :permalink
  # TODO: #1115, review authorization
  load_and_authorize_resource :find_by => :permalink, :class => MwebEvents::Event

  # need it to show info in the sidebar
  before_filter :webconf_room!

  # TODO: everything is being filtered by software, this can all be done with db queries
  def index
    all_events = @space.events(:order => "end_on DESC")

    # events happening now
    @current_events = all_events.happening_now

    if params[:show] == 'past_events'
      @past_events = all_events.past
      @past_events = @past_events.reverse_order if params[:order_by_time] != "ASC"
      @past_events = @past_events.paginate(:page => params[:page], :per_page => 5)

    elsif params[:show] == 'upcoming_events'
      @upcoming_events = all_events.upcoming
      @upcoming_events = @upcoming_events.paginate(:page => params[:page], :per_page => 10)

    elsif params[:show] == 'happening_now'
      @current_events = @current_events.paginate(:page => params[:page], :per_page => 5)

    # the 'default' index
    else
      @last_past_events = all_events.past.first(3)
      @first_upcoming_events = all_events.upcoming.first(3)
    end
  end

end
