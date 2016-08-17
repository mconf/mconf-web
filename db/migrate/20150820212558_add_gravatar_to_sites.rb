class AddGravatarToSites < ActiveRecord::Migration
  def change
    add_column :sites, :use_gravatar, :boolean, default: false
  end
end
