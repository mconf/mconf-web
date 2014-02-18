class RemoveParticipants < ActiveRecord::Migration
  def up
    drop_table :participants
  end

  def down
    throw ActiveRecord::IrreversibleMigration
  end
end
