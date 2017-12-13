# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class SpaceEventsController < ApplicationController
  layout "application"

  before_filter :require_spaces_mod
  before_filter :require_events_mod

  load_and_authorize_resource :space, :find_by => :slug
  load_and_authorize_resource :find_by => :slug, :class => Event

  # need it to show info in the sidebar
  before_filter :webconf_room!

  def index
    authorize! :index_event, @space

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

    else # 'all'
      @last_past_events = all_events.past.first(3)
      @first_upcoming_events = all_events.upcoming.first(3)
    end
  end

end
