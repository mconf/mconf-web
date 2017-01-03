class SetDefaultValuesOnBigbluebuttonRoomsFlags < ActiveRecord::Migration
  def up
    tbl = BigbluebuttonRoomOptions.arel_table
    presenter_share_only = tbl[:presenter_share_only].not_eq(nil)
    auto_start_video = tbl[:auto_start_video].not_eq(nil)
    audo_start_audio = tbl[:auto_start_audio].not_eq(nil)
    query = BigbluebuttonRoomOptions.where(audo_start_audio.or(auto_start_video.or(presenter_share_only)))
    query.find_each do |opts|
      room = opts.room
      puts "Setting default value (NULL) on the flags of room (#{room.id}, #{room.meetingid}) that were #{flags_str(room)}"
      opts.update_attributes(auto_start_audio: nil, auto_start_video: nil, presenter_share_only: nil)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  def flags_str(room)
    room.room_options.attributes.select{ |k,v| ['auto_start_audio', 'auto_start_video', 'presenter_share_only'].include?(k) }
  end
end
