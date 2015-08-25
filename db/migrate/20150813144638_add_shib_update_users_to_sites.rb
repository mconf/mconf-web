class AddShibUpdateUsersToSites < ActiveRecord::Migration
  def change
    add_column :sites, :shib_update_users, :boolean, default: false
  end
end
