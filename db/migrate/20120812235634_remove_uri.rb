class RemoveUri < ActiveRecord::Migration
  def up
    drop_table :uris
  end

  def down
    throw ActiveRecord::IrreversibleMigration
  end
end
