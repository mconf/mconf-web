class DropPrivateMessages < ActiveRecord::Migration
  def change
  	drop_table :private_messages
  end
end
