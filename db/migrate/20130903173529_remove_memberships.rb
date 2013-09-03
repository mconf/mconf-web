class RemoveMemberships < ActiveRecord::Migration
  def up
    drop_table :memberships
  end

  def down
    throw ActiveRecord::IrreversibleMigration
  end
end
