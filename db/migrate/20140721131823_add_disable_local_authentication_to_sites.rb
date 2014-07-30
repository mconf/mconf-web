class AddDisableLocalAuthenticationToSites < ActiveRecord::Migration
  def up
    add_column :sites, :disable_local_auth, :boolean, :default => false
  end

  def down
    remove_column :sites, :disable_local_auth
  end
end
