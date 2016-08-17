class BigbluebuttonRailsTo200H < ActiveRecord::Migration
  def change
    add_column :bigbluebutton_room_options, :background, :string
  end
end
