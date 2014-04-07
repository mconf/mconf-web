class AddRegistrationsEnabledToSites < ActiveRecord::Migration
  def change
    add_column :sites, :registration_enabled, :boolean, :default => true, :null => false
  end
end
