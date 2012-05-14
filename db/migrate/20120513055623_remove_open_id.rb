class RemoveOpenId < ActiveRecord::Migration
  def up
    drop_table :open_id_associations
    drop_table :open_id_nonces
    drop_table :open_id_ownings
    drop_table :open_id_trusts
  end

  def down
    throw ActiveRecord::IrreversibleMigration
  end
end
