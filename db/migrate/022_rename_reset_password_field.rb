class RenameResetPasswordField < ActiveRecord::Migration
  def self.up
    rename_column :users, :password_reset_code, :reset_password_code
  end

  def self.down
    rename_column :users, :reset_password_code, :password_reset_code   
  end
end
