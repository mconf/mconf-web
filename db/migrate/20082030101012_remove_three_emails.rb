class RemoveThreeEmails < ActiveRecord::Migration
  def self.up
    remove_column "users", "email2" 
    remove_column "users", "email3"
  end

  def self.down
    add_column "users", "email2", :string
    add_column "users", "email3", :string
  end
end
