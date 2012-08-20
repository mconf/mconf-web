class RemoveOldPermissions < ActiveRecord::Migration
  def up
    old_roles = [['Speaker', 'AgendaEntry'], ['Translator', 'Site'],
                 ['Invitedevent', 'Event'], ['Invited', 'Space']]
    for role in old_roles
      r = Role.where(:name => role[0], :stage_type => role[1]).first
      r.destroy if r
    end
    drop_table :permissions_roles
    drop_table :permissions
    drop_table :performances
    rename_table :permissions_tmp, :permissions
  end

  def down
    throw ActiveRecord::IrreversibleMigration
  end
end
