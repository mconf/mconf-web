class AttachmentRefactorized < ActiveRecord::Migration
  def self.up
    add_column :attachments, :version_child_id, :integer
    add_column :attachments, :version_family_id, :integer
    add_index :attachments, :version_child_id 
    add_index :attachments, :version_family_id

    remove_column :post_attachments, :attachment_version

    drop_table :versions
  end

  def self.down
  end
end
