# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'version'

module CustomBigbluebuttonRoomsHelper

  # Returns a BigbluebuttonMetadata model from the BigbluebuttonRoom `room` that has the
  # name `name`.
  def get_room_metadata(room, name)
    room.metadata.all.select{ |m| m.name == name }.first
  end

end
