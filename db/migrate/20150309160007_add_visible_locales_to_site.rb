class AddVisibleLocalesToSite < ActiveRecord::Migration
  def change
    add_column :sites, :visible_locales, :string, default: ["en", "pt-br"]
  end
end
