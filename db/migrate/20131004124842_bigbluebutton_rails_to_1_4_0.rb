class BigbluebuttonRailsTo140 < ActiveRecord::Migration
  def self.up
    add_column :bigbluebutton_recordings, :description, :text
  end

  def self.down
    remove_column :bigbluebutton_recordings, :description
  end
end
