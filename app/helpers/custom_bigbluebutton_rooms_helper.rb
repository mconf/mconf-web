require 'version'

module CustomBigbluebuttonRoomsHelper

  # Returns a BigbluebuttonMetadata model from the BigbluebuttonRoom `room` that has the
  # name `name`.
  def get_room_metadata(room, name)
    room.metadata.all.select{ |m| m.name == name }.first
  end

end
