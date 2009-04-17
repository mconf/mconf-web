class DeleteMessages < ActiveRecord::Migration
  def self.up
    add_column :private_messages, :deleted_by_sender, :boolean, :default => false
    add_column :private_messages, :deleted_by_receiver, :boolean, :default => false
  end

  def self.down
    remove_column :private_messages, :deleted_by_sender
    remove_column :private_messages, :deleted_by_receiver
  end
end
