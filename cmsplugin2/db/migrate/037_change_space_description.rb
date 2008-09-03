class ChangeSpaceDescription < ActiveRecord::Migration
  def self.up
    remove_column "spaces", :description
    add_column "spaces", "description", :text     
  end

  def self.down
    
  end
end
