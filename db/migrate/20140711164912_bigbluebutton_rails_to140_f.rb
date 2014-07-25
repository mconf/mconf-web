class BigbluebuttonRailsTo140F < ActiveRecord::Migration
  def up
    add_column :bigbluebutton_room_options, :auto_start_video, :boolean
    add_column :bigbluebutton_room_options, :auto_start_audio, :boolean
  end

  def down
    remove_column :bigbluebutton_room_options, :auto_start_video
    remove_column :bigbluebutton_room_options, :auto_start_audio
  end
end
