class EventPost < ActiveRecord::Migration
  def self.up
    add_column :events, :post_id, :integer
  end

  def self.down
    remove_column  :events, :post_id
  end
end
