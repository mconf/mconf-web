class Memberships < ActiveRecord::Migration
  def self.up
    rename_table "groups_users", "memberships"
    add_column "memberships", "id", :primary_key
    add_column "memberships", "manager", :boolean, {:default => false}
  end

  def self.down
    remove_column "memberships", "manager"
    remove_column "memberships", "id"
    rename_table "memberships", "groups_users"
  end
end
