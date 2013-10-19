class BigbluebuttonRailsTo140B < ActiveRecord::Migration
  def self.up
    add_column :bigbluebutton_recordings, :meeting_id, :integer

    create_table :bigbluebutton_meetings do |t|
      t.integer :server_id
      t.integer :room_id
      t.string :meetingid
      t.string :name
      t.datetime :start_time
      t.boolean :running, :default => false
      t.boolean :record, :default => false
      t.timestamps
    end
    add_index :bigbluebutton_meetings, [:meetingid, :start_time], :unique => true
  end

  def self.down
    drop_table :bigbluebutton_meetings
    remove_column :bigbluebutton_recordings, :meeting_id
  end
end
