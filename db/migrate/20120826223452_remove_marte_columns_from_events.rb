class RemoveMarteColumnsFromEvents < ActiveRecord::Migration
  def up
    remove_column :events, :marte_event
    remove_column :events, :marte_room
  end

  def down
    throw ActiveRecord::IrreversibleMigration
  end
end
