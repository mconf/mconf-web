class AddTimezoneToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :timezone, :string, :default => 'Brasilia'
  end

  def self.down
    remove_column :sites, :timezone
  end
end
