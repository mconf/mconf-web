class RenamePermalinkToSlug < ActiveRecord::Migration
  def change
    rename_column :spaces, :permalink, :slug
    rename_column :events, :permalink, :slug
  end
end
