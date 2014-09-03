class BigbluebuttonRailsTo200C < ActiveRecord::Migration
  def change
    add_column :bigbluebutton_rooms, :create_time, :decimal, precision: 14, scale: 0
  end
end
