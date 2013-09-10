class RemoveLogos < ActiveRecord::Migration
  def up
    drop_table :logos
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
