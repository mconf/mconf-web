class AddShibbolethToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :shib_enabled, :boolean, :default => false
    add_column :sites, :shib_name_field, :string
    add_column :sites, :shib_email_field, :string
  end

  def self.down
    remove_column :sites, :shib_email_field
    remove_column :sites, :shib_name_field
    remove_column :sites, :shib_enabled
  end
end
