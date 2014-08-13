class BigbluebuttonRailsTo200B < ActiveRecord::Migration
  def self.up
    add_column :bigbluebutton_rooms, :create_time, :string
  end

  def self.down
    remove_column :bigbluebutton_rooms, :create_time
  end
end
