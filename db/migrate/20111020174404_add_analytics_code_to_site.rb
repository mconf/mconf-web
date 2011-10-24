class AddAnalyticsCodeToSite < ActiveRecord::Migration
  def self.up
    add_column :sites, :analytics_code, :string
  end

  def self.down
    remove_column :sites, :analytics_code
  end
end
