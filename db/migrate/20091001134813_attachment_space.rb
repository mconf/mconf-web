class AttachmentSpace < ActiveRecord::Migration

  class AttachmentMigration < ActiveRecord::Base
    self.table_name = "attachments"

    belongs_to :post
    belongs_to :space
  end

  def self.up
    add_column :attachments, :space_id, :integer
    add_column :attachments, :event_id, :integer

    AttachmentMigration.record_timestamps = false
    AttachmentMigration.all.each do |a|
      unless a.post.blank?
        a.space = a.post.space
        a.save
      end
    end

    Attachment.reset_column_information
    Attachment.all.each do |a|
      a.save #All attachments are resaved to add the first version
    end
  end

  def self.down
    remove_column :attachments, :event_id
    remove_column :attachments, :space_id
  end
end

