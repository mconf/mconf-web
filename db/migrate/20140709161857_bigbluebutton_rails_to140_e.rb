class BigbluebuttonRailsTo140E < ActiveRecord::Migration
  def up
    add_column :bigbluebutton_room_options, :presenter_share_only, :boolean
  end

  def down
    remove_column :bigbluebutton_room_options, :presenter_share_only
  end
end
