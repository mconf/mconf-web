class ModifyUsersProfile < ActiveRecord::Migration
  def self.up
    remove_column "profiles", "user_id"
    add_column "profiles", "users_id", :integer
  end

  def self.down
    add_column "profiles", "user_id", :integer
    remove_column "profiles", "users_id"
  end
end
