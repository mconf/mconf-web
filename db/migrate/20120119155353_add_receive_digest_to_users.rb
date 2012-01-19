class AddReceiveDigestToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :receive_digest, :integer, :default => 0

    User.all.each { |u| u.update_attributes(:receive_digest => 0) }
  end

  def self.down
    remove_column :users, :receive_digest
  end
end
