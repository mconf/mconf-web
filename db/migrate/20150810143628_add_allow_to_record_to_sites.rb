class AddAllowToRecordToSites < ActiveRecord::Migration
  def change
  	add_column :sites, :allow_to_record, :string
  end
end
