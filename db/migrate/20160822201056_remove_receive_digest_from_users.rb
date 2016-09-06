class RemoveReceiveDigestFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :receive_digest
  end

  def down
    throw ActiveRecord::IrreversibleMigration
  end
end
