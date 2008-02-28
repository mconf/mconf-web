class ChangeUserMachine < ActiveRecord::Migration
  def self.up
    create_table :machines_users, :id => false do |t|
      t.column :user_id, :integer, :null=>false
      t.column :machine_id, :integer, :null=>false
    end
    drop_table :users_machines
  end

  def self.down
    drop_table :machines_users
     create_table :users_machines do |t|
      t.column :user_id, :integer, :null=>false
      t.column :machine_id, :integer, :null=>false
    end
  end
end
