class RemoveOldPermissions < ActiveRecord::Migration
  def up
    Role.where(:name => 'Speaker', :stage_type => 'AgendaEntry').first.destroy
    Role.where(:name => 'Translator', :stage_type => 'Site').first.destroy
    Role.where(:name => 'Invitedevent', :stage_type => 'Event').first.destroy
    Role.where(:name => 'Invited', :stage_type => 'Space').first.destroy
    drop_table :permissions_roles
    drop_table :permissions
    drop_table :performances
    rename_table :permissions_tmp, :permissions
  end

  def down
    throw ActiveRecord::IrreversibleMigration
  end
end
