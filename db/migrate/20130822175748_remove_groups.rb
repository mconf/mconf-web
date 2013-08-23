class RemoveGroups < ActiveRecord::Migration
  def up
    drop_table :groups
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
