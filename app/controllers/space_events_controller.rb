# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class SpaceEventsController < ApplicationController

  layout "spaces_show"

  load_and_authorize_resource :space, :find_by => :permalink
  # TODO: #1115, review authorization
  load_and_authorize_resource :find_by => :permalink, :class => MwebEvents::Event

  # need it to show info in the sidebar
  before_filter :webconf_room!

  # TODO: everything is being filtered by software, this can all be done with db queries
  def index
    all_events = @space.events(:order => "start_on ASC")

    # events happening now
    @current_events = all_events.select{ |e| e.is_happening_now? }

    if params[:show] == 'past_events'
      @past_events = all_events.select{ |e| !e.end_on.future? }
      @past_events.reverse! if params[:order_by_time] == "DESC"
      @past_events = @past_events.paginate(:page => params[:page], :per_page => 5)

    elsif params[:show] == 'upcoming_events'
      @upcoming_events = all_events.select{ |e| e.start_on.future? }
      @upcoming_events = @upcoming_events.paginate(:page => params[:page], :per_page => 10)

    # the 'default' index
    else
      @last_past_events = all_events.select{ |e| !e.end_on.future? }.first(3)
      @first_upcoming_events = all_events.select{ |e| e.start_on.future? }.first(3)
    end
  end

end
