class CreateColumnSpaceInGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :space_id, :integer
    
    
  end

  def self.down
    remove_column :groups, :space_id
  end
end
