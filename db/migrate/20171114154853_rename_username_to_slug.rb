class RenameUsernameToSlug < ActiveRecord::Migration
  def change
    rename_column :users, :username, :slug
  end
end
