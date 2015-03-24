# This is a duplicate of BigbluebuttonRailsTo140. It is here because BigbluebuttonRailsTo140
# was modified but there were already some instances of Mconf-Web that already ran
# BigbluebuttonRailsTo140, so we have to to it again for these instances.
class BigbluebuttonRailsTo140Duplicate < ActiveRecord::Migration
  def self.up
    change_column :bigbluebutton_recordings, :description, :text
  end

  def self.down
    change_column :bigbluebutton_recordings, :description, :string
  end
end
