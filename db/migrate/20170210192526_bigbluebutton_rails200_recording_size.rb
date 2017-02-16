class BigbluebuttonRails200RecordingSize < ActiveRecord::Migration
  def change
    change_column :bigbluebutton_recordings, :size, :integer, limit: 8, default: 0
  end
end
