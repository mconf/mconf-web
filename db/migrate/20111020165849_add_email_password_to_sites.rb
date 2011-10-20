class AddEmailPasswordToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :email_password, :string
  end

  def self.down
    remove_column :sites, :email_password
  end
end
