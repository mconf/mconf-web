class VarcharToString < ActiveRecord::Migration
  def self.up
    change_column  :events,  :description, :text
    change_column  :private_messages,  :body,  :text
  end

  def self.down
    change_column  :events,  :description,  :string
    change_column  :private_messages,  :body,  :string
  end
end
