class PostAttachments < ActiveRecord::Migration
  def self.up
    create_table :post_attachments do |t|
      t.references :post
      t.references :attachment
      t.integer :attachment_version
    end
    
    Attachment.all.each do |a|
      next if a.post_id.blank?
      
      PostAttachment.create(:post_id => a.post_id, :attachment_id => a.id, :attachment_version => a.version)
    end
    
    remove_column :attachments, :post_id
  end

  def self.down
    add_column :attachments, :post_id, :integer
    drop_table :post_attachments
  end
end
