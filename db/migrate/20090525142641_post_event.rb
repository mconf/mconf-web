class PostEvent < ActiveRecord::Migration
  def self.up
    remove_column  :events, :post_id
    add_column :posts, :event_id, :integer
  end

  def self.down
    add_column :events, :post_id, :integer
    remove_column :posts, :event_id
  end
end
