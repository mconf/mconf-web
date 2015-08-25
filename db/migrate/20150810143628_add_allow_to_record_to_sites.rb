class AddAllowToRecordToSites < ActiveRecord::Migration
  def change
    add_column :sites, :allowed_to_record, :string
  end
end
