class AddQualityToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :isabel_bw, :text
    add_column :events, :web_bw, :integer
    add_column :events, :recording_bw, :integer
  end

  def self.down
    remove_column :events, :isabel_bw
    remove_column :events, :web_bw
    remove_column :events, :recording_bw
  end
end
