class BigbluebuttonRailsTo130B < ActiveRecord::Migration

  def self.up
    # columns removed in 1.3.0, but after we were already using it, so they can't
    # be in the default migration to 1.3.0
    remove_column :bigbluebutton_rooms, :randomize_meetingid
    remove_index :bigbluebutton_rooms, :uniqueid
    remove_column :bigbluebutton_rooms, :uniqueid

    # Generate a globally unique meetingID for every room
    BigbluebuttonRoom.all.each do |room|
      room.update_attribute(:meetingid, room.unique_meetingid)
    end
  end

  def self.down
    add_column :bigbluebutton_rooms, :uniqueid, :string, :null => false
    add_index :bigbluebutton_rooms, :uniqueid, :unique => true
    add_column :bigbluebutton_rooms, :randomize_meetingid, :boolean, :default => true
    # Can't undo meetingIDs
  end
end
