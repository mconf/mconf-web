class CreateBigbluebuttonRails < ActiveRecord::Migration

  def self.up
    create_table :bigbluebutton_servers do |t|
      t.string :name
      t.string :url
      t.string :salt
      t.string :version
      t.timestamps
    end
    create_table :bigbluebutton_rooms do |t|
      t.integer :server_id
      t.integer :owner_id
      t.string :owner_type
      t.string :meetingid
      t.string :name
      t.string :attendee_password
      t.string :moderator_password
      t.string :welcome_msg
      t.string :logout_url
      t.string :voice_bridge
      t.string :dial_number
      t.integer :max_participants
      t.boolean :private, :default => false
      t.boolean :randomize_meetingid, :default => true
      t.timestamps
    end
    add_index :bigbluebutton_rooms, :server_id
    add_index :bigbluebutton_rooms, :meetingid, :unique => true
    add_index :bigbluebutton_rooms, :voice_bridge, :unique => true
  end

  def self.down
    drop_table :bigbluebutton_rooms
    drop_table :bigbluebutton_servers
  end

end
