class AddAttachmentToAgenda < ActiveRecord::Migration
  def self.up
    add_column :attachments, :agenda_id, :integer
  end

  def self.down
    remove_column :attachments, :agenda_id
  end
end
