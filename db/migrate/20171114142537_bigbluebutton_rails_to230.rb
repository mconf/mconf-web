class BigbluebuttonRailsTo230 < ActiveRecord::Migration
  def up
    add_column :bigbluebutton_recordings, :recording_users, :text
    add_column :bigbluebutton_playback_types, :downloadable, :boolean, default: false
  end

  def down
    remove_column :bigbluebutton_playback_types, :downloadable
    remove_column :bigbluebutton_recordings, :recording_users
  end
end
