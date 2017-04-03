class BigbluebuttonRailsTo200I < ActiveRecord::Migration
  def change
    add_column :bigbluebutton_recordings, :size, :integer, limit: 8, default: 0
  end
end
