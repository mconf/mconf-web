class BigbluebuttonRailsTo140D < ActiveRecord::Migration
  def up
    add_column :bigbluebutton_meetings, :creator_id, :integer
    add_column :bigbluebutton_meetings, :creator_name, :string
  end

  def down
    remove_column :bigbluebutton_meetings, :creator_name
    remove_column :bigbluebutton_meetings, :creator_id
  end
end
