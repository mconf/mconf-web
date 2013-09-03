class RemoveMachines < ActiveRecord::Migration
  def up
    drop_table :machines
    drop_table :machines_users
  end

  def down
    throw ActiveRecord::IrreversibleMigration
  end
end
