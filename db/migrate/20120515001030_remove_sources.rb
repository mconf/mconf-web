class RemoveSources < ActiveRecord::Migration
  def up
    drop_table :source_importations
    drop_table :sources
  end

  def down
    throw ActiveRecord::IrreversibleMigration
  end
end
