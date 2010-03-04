class SitesPresenceDomain < ActiveRecord::Migration
  def self.up
    add_column :sites, :presence_domain, :string
  end

  def self.down
    remove_column :sites, :presence_domain
  end
end
