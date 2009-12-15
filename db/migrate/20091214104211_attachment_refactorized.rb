class AttachmentRefactorized < ActiveRecord::Migration

  class AttachmentMigration < ActiveRecord::Base
    set_table_name "attachments"
  end
  
  def self.up
    add_column :attachments, :version_child_id, :integer
    add_column :attachments, :version_family_id, :integer
    add_index :attachments, :version_child_id 
    add_index :attachments, :version_family_id

    remove_column :post_attachments, :attachment_version

    drop_table :versions

    AttachmentMigration.record_timestamps = false
    AttachmentMigration.all.each do |a|
      a.update_attribute(:version_family_id, a.id)
    end
  end

  def self.down
  end
end
