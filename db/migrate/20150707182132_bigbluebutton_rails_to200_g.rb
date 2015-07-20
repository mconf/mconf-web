class BigbluebuttonRailsTo200G < ActiveRecord::Migration
  def up
    add_column :bigbluebutton_rooms, :moderator_only_message, :string
    add_column :bigbluebutton_rooms, :auto_start_recording, :boolean
    add_column :bigbluebutton_rooms, :allow_start_stop_recording, :boolean
  end

  def down
    remove_column :bigbluebutton_rooms, :moderator_only_message
    remove_column :bigbluebutton_rooms, :auto_start_recording
    remove_column :bigbluebutton_rooms, :allow_start_stop_recording
  end
end
