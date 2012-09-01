# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class StatisticsController < ApplicationController
  layout 'no_sidebar'

  def show
    @user_count = User.count
    @space_count = Space.count
    @event_count = Event.count
    @post_count = Post.count
    @webconf_room_count = BigbluebuttonRoom.count
    @private_message_count = PrivateMessage.count

    # TODO: not very effective, should be made async by the client, or maybe
    #       we don't really need this here in the web portal'
    # @meeting_count = BigbluebuttonServer.all.inject(0) do |sum, server|
    #   server.fetch_meetings
    #   sum + server.meetings.select { |m| m.is_running? }.count
    # end
  end
end
