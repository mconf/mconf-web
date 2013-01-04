class AddShibLoginFieldToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :shib_login_field, :string
  end

  def self.down
    remove_column :sites, :shib_login_field
  end
end
