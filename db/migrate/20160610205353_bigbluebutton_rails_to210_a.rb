class BigbluebuttonRailsTo210A < ActiveRecord::Migration
  def self.up
    add_column :bigbluebutton_meetings, :server_url, :string
    add_column :bigbluebutton_meetings, :server_secret, :string
    add_column :bigbluebutton_meetings, :create_time, :decimal, precision: 14, scale: 0
    add_column :bigbluebutton_meetings, :ended, :boolean, :default => false
    remove_index :bigbluebutton_meetings, [:meetingid, :start_time]
    add_index :bigbluebutton_meetings, [:meetingid, :create_time], :unique => true
    rename_column :bigbluebutton_servers, :salt, :secret
  end

  def self.down
    remove_column :bigbluebutton_meetings, :server_url
    remove_column :bigbluebutton_meetings, :server_secret
    remove_column :bigbluebutton_meetings, :create_time
    remove_column :bigbluebutton_meetings, :ended
    remove_index :bigbluebutton_meetings, [:meetingid, :create_time]
    add_index :bigbluebutton_meetings, [:meetingid, :start_time], :unique => true
    rename_column :bigbluebutton_servers, :secret, :salt
  end
end
