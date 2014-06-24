class AddEventsEnabledToSites < ActiveRecord::Migration
  def change
    add_column :sites, :events_enabled, :boolean, :default => false
  end
end
