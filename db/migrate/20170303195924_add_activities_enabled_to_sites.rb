class AddActivitiesEnabledToSites < ActiveRecord::Migration
  def change
    add_column :sites, :activities_enabled, :boolean, default: true
  end
end
