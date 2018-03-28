class BigbluebuttonRailsTo230 < ActiveRecord::Migration
  def up
    rename_column :bigbluebutton_rooms, :param, :slug
    rename_column :bigbluebutton_servers, :param, :slug
    add_column :bigbluebutton_recordings, :recording_users, :text
    add_column :bigbluebutton_playback_types, :downloadable, :boolean, default: false
  end

  def down
    remove_column :bigbluebutton_playback_types, :downloadable
    rename_column :bigbluebutton_servers, :slug, :param
    rename_column :bigbluebutton_rooms, :slug, :param
    remove_column :bigbluebutton_recordings, :recording_users
  end
end
