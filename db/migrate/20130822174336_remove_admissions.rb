class RemoveAdmissions < ActiveRecord::Migration
  def up
    drop_table :admissions
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
