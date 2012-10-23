# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class CustomBigbluebuttonServersController < Bigbluebutton::ServersController
  before_filter :authenticate_user!
  after_filter :sort_meetings, :only => [:activity]
  authorize_resource :class => "BigbluebuttonServer"

  def sort_meetings
    @server.meetings.sort{|m1,m2| m1.name <=> m2.name }
  end
end
