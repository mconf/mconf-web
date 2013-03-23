class BigbluebuttonRailsTo130 < ActiveRecord::Migration

  def self.up
    create_table :bigbluebutton_recordings do |t|
      t.integer :server_id
      t.integer :room_id
      t.string :recordid
      t.string :meetingid
      t.string :name
      t.boolean :published, :default => false
      t.datetime :start_time
      t.datetime :end_time
      t.boolean :available, :default => true
      t.timestamps
    end
    add_index :bigbluebutton_recordings, :room_id
    add_index :bigbluebutton_recordings, :recordid, :unique => true

    create_table :bigbluebutton_metadata do |t|
      t.integer :owner_id
      t.string :owner_type
      t.string :name
      t.text :content
      t.timestamps
    end

    create_table :bigbluebutton_playback_formats do |t|
      t.integer :recording_id
      t.string :format_type
      t.string :url
      t.integer :length
      t.timestamps
    end

    change_table(:bigbluebutton_rooms) do |t|
      t.boolean :record, :default => false
      t.integer :duration, :default => 0
      t.string :uniqueid, :null => false
    end
    # Ensure all rooms will have :uniqueid set
    BigbluebuttonRoom.all.each_with_index do |room, i|
      room.uniqueid = "#{SecureRandom.hex(16)}-#{Time.now.to_i}#{i}"
      room.save(:validate => false)
    end
    add_index :bigbluebutton_rooms, :uniqueid, :unique => true
  end

  def self.down
    remove_index :bigbluebutton_rooms, :uniqueid
    change_table(:bigbluebutton_rooms) do |t|
      t.remove :record
      t.remove :duration
      t.remove :uniqueid
    end
    drop_table :bigbluebutton_playback_formats
    drop_table :bigbluebutton_metadata
    drop_table :bigbluebutton_recordings
  end
end
