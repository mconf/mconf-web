class CreateUsersMachines < ActiveRecord::Migration
  def self.up
    create_table :users_machines do |t|
      t.column :user_id, :integer, :null=>false
      t.column :resource_id, :integer, :null=>false
    end
  end

  def self.down
    drop_table :users_machines
  end
end
