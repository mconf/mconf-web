class AddMaxUploadSizeToSite < ActiveRecord::Migration
  def change
    add_column :sites, :max_upload_size, :string
  end
end
