class AddWebconfAutoRecordToSites < ActiveRecord::Migration
  def up
    add_column :sites, :webconf_auto_record, :boolean, :default => false
  end

  def down
    remove_column :sites, :webconf_auto_record
  end
end
