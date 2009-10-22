class AddExternalStreaming < ActiveRecord::Migration
  def self.up
    add_column :events, :other_streaming_url, :text
  end

  def self.down
    remove_column :events, :other_streaming_url
  end
end
