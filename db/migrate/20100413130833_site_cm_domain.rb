class SiteCmDomain < ActiveRecord::Migration
  def self.up
    add_column :sites, :cm_domain, :string
  end

  def self.down
    remove_column :sites, :cm_domain
  end
end
