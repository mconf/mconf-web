class AttachmentAuthor < ActiveRecord::Migration

  class AttachmentMigration < ActiveRecord::Base
    self.table_name = "attachments"
    belongs_to :author, :polymorphic => true
    belongs_to :post
  end

  def self.up
    add_column :attachments, :author_id, :integer
    add_column :attachments, :author_type, :string

    AttachmentMigration.record_timestamps = false
    AttachmentMigration.all.each do |a|
      unless a.post.blank?
        a.author = a.post.author
        a.save
      end
    end

  end

  def self.down
    remove_column :attachments, :author_id
    remove_column :attachments, :author_type
  end
end
