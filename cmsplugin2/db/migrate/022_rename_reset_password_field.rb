class RenameResetPasswordField < ActiveRecord::Migration
  def self.up
    rename_column :users, :password_reset_code, :reset_password_code
    directory = File.join(File.dirname(__FILE__), "data")
    Fixtures.create_fixtures(directory, "users")
  end

  def self.down
    rename_column :users, :reset_password_code, :password_reset_code
    User.delete_all
  end
end
