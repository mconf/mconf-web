# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class BigbluebuttonRoomObserver < ActiveRecord::Observer
  observe :bigbluebutton_room

  def after_create(room)
    create_metadata(room)
  end

  def after_update(room)
    create_metadata(room)
  end

  protected

  def create_metadata(room)
    name = configatron.webconf.metadata.title
    title = room.metadata.where(:name => name).first
    room.metadata.create(:name => name) if title.nil?

    name = configatron.webconf.metadata.description
    description = room.metadata.where(:name => name).first
    room.metadata.create(:name => name) if description.nil?
  end
end
