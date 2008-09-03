class UpdateUserActivation < ActiveRecord::Migration
  def self.up
    add_column :users, :activation_code, :string, :limit => 40
    add_column :users, :activated_at, :datetime
    remove_column :users, :email_confirmed
  end

  def self.down
    remove_column :users, :activation_code
    remove_column :users, :activated_at
    add_column :users, :email_confirmed, :boolean, :default => false
  end
end
