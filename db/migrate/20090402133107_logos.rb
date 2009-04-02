class Logos < ActiveRecord::Migration
  def self.up
    rename_table :logotypes, :logos
    rename_column :logos, :logotypable_id, :logoable_id
    rename_column :logos, :logotypable_type, :logoable_type
  end

  def self.down
    rename_column :logos, :logoable_id, :logotypable_id
    rename_column :logos, :logoable_type, :logotypable_type
    rename_table :logos, :logotypes
  end
end
