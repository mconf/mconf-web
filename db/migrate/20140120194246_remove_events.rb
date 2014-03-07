class RemoveEvents < ActiveRecord::Migration
  def up
    drop_table :events
  end

  def down
    throw ActiveRecord::IrreversibleMigration
  end
end
