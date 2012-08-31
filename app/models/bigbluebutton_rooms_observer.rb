# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class BigbluebuttonRoomsObserver < ActiveRecord::Observer
  observe :profile

  def after_update(profile)
    if profile.user and profile.user.bigbluebutton_room
      profile.user.bigbluebutton_room.update_attribute(:name, profile.full_name)
    end
  end
end
