class ChangeProfile < ActiveRecord::Migration
  def self.up
    add_column "profiles","user_id",  :string
    remove_column "profiles","users_id"
  end

  def self.down
    remove_column "profiles","user_id"
    add_column "profiles","users_id", :string
  end
end
