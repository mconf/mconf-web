class RemoveUnusedInformationFromAttachments < ActiveRecord::Migration
  def up
    remove_column :attachments, :filename
    remove_column :attachments, :height
    remove_column :attachments, :width
    remove_column :attachments, :parent_id
    remove_column :attachments, :thumbnail
    remove_column :attachments, :db_file_id
    remove_column :attachments, :version_child_id
    remove_column :attachments, :version_family_id
  end

  def down
    add_column :attachments, :filename, :string
    add_column :attachments, :height, :integer
    add_column :attachments, :width, :integer
    add_column :attachments, :parent_id, :integer
    add_column :attachments, :thumbnail, :string
    add_column :attachments, :db_file_id, :integer
    add_column :attachments, :version_child_id, :integer
    add_column :attachments, :version_family_id, :integer
  end
end
