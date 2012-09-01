# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class CustomBigbluebuttonRoomsController < Bigbluebutton::RoomsController
  before_filter :authenticate_user!,
    :except => [:invite, :auth, :running, :external]
  authorize_resource :class => "BigbluebuttonRoom",
    :except => [:invite, :auth, :running, :join, :end, :external, :join_mobile]
  layout 'application', :except => [:join_mobile]
  layout 'no_sidebar'
end
