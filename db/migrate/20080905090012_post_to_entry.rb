class PostToEntry < ActiveRecord::Migration
  def self.up
    rename_column :categorizations, :post_id, :entry_id
    rename_table :posts, :entries
    rename_column :roles, :create_posts, :create_entries
    rename_column :roles, :read_posts, :read_entries
    rename_column :roles, :update_posts, :update_entries
    rename_column :roles, :delete_posts, :delete_entries
  end

  def self.down
    rename_column :categorizations, :entry_id, :post_id
    rename_table :entries, :posts
    rename_column :roles, :create_entries, :create_posts
    rename_column :roles, :read_entries, :read_posts
    rename_column :roles, :update_entries, :update_posts
    rename_column :roles, :delete_entries, :delete_posts
  end
end
