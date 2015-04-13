class BigbluebuttonRailsTo200E < ActiveRecord::Migration
  def up
    if index_exists?(:bigbluebutton_rooms, :voice_bridge)
      remove_index :bigbluebutton_rooms, :voice_bridge
    end
  end

  def down
    unless index_exists?(:bigbluebutton_rooms, :voice_bridge)
      add_index :bigbluebutton_rooms, :voice_bridge, unique: true
    end
  end
end
