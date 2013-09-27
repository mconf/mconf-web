class RenameEmailToSites < ActiveRecord::Migration
  def self.up
    rename_column :sites, :email, :smtp_login
    rename_column :sites, :email_password, :smtp_password
  end

  def self.down
    rename_column :sites, :smtp_login, :email
    rename_column :sites, :smtp_password, :email_password
  end
end
