class AddDisableLocalAuthenticationToSites < ActiveRecord::Migration
  def up
    add_column :sites, :local_auth_enabled, :boolean, :default => true
  end

  def down
    remove_column :sites, :local_auth_enabled
  end
end
