class AddMaxUploadSizeToSite < ActiveRecord::Migration
  def change
    add_column :sites, :max_upload_size, :string, default: "15000000"
  end
end
