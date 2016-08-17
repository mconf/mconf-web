# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class StatisticsController < ApplicationController
  layout 'no_sidebar'

  before_filter :load_events, :only => :show, :if => lambda { Mconf::Modules.mod_enabled?('events') }

  def show
    @user_count = User.count
    @space_count = Space.count
    @post_count = Post.count
    @webconf_room_count = BigbluebuttonRoom.count
  end

  private

  def load_events
    @event_count = Event.count
  end

end
