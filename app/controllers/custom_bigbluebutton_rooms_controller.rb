# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class CustomBigbluebuttonRoomsController < Bigbluebutton::RoomsController
  # the exceptions are all used in the invitation page and should be accessible even to
  # anonymous users
  before_filter :authenticate_user!,
    :except => [:invite, :invite_userid, :auth, :running]

  # some routes are accessible to everyone, but some of them will do the authorization
  # themselves (e.g. permissions for :join will change depending on the user and the target
  # room)
  load_resource :find_by => :param, :class => "BigbluebuttonRoom"
  authorize_resource :class => "BigbluebuttonRoom",
    :except => [:invite, :invite_userid, :join, :auth, :join_mobile, :running,
                :external, :external_auth]

  layout "application", :except => [:join_mobile]
  layout false, :only => [:join_mobile]
end
