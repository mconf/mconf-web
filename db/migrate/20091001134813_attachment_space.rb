class AttachmentSpace < ActiveRecord::Migration
  def self.up
    add_column :attachments, :space_id, :integer
    add_column :attachments, :event_id, :integer
    Attachment.reset_column_information
    Attachment.record_timestamps = false
    Attachment.all.each do |a|
      a.space = a.post.space unless a.post.blank?
      a.save #All attachments are resaved to add the first version
    end
  end

  def self.down
    remove_column :attachments, :event_id
    remove_column :attachments, :space_id
  end
end
