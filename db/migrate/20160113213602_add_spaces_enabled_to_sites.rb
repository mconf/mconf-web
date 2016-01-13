class AddSpacesEnabledToSites < ActiveRecord::Migration
  def change
    add_column :sites, :spaces_enabled, :boolean, default: true
  end
end
