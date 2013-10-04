class BigbluebuttonRailsTo140 < ActiveRecord::Migration
  def self.up
    add_column :bigbluebutton_recordings, :description, :string
  end

  def self.down
    remove_column :bigbluebutton_recordings, :description
  end
end
