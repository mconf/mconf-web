class RemoveWebconfAutoRecordFromSites < ActiveRecord::Migration
  def change
    remove_column :sites, :webconf_auto_record, :boolean
  end
end
