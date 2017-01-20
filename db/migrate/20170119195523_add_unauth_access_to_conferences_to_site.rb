class AddUnauthAccessToConferencesToSite < ActiveRecord::Migration
  def change
    add_column :sites, :unauth_access_to_conferences, :boolean, default: true
  end
end
