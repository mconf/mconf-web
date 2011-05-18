class AddSignatureToSite < ActiveRecord::Migration
  def self.up
    add_column :sites, :signature, :text
  end

  def self.down
    remove_column :sites, :signature
  end
end
