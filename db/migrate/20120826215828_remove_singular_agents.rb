class RemoveSingularAgents < ActiveRecord::Migration
  def up
    drop_table :singular_agents
  end

  def down
    throw ActiveRecord::IrreversibleMigration
  end
end
