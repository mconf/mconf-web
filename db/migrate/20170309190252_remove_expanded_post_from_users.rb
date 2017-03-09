class RemoveExpandedPostFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :expanded_post, :boolean
  end
end
