class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.string :name

      t.timestamps
    end
    
    create_table :groups_users do |t|
      t.integer :group_id
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :groups
    drop_table :groups_users
  end
end
