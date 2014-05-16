class RemoveTagsAndTaggings < ActiveRecord::Migration
  def up
    drop_table :tags
    drop_table :taggings
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
