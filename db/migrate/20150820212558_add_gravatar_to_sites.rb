class AddGravatarToSites < ActiveRecord::Migration
  def change
    add_column :sites, :gravatar, :boolean, default: false
  end
end
