class BigbluebuttonRailsTo200E < ActiveRecord::Migration
  def up
    remove_index :bigbluebutton_rooms, :voice_bridge
  end

  def down
    add_index :bigbluebutton_rooms, :voice_bridge, :unique => true
  end
end
