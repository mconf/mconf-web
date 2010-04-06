class AddChatGroupServiceJid < ActiveRecord::Migration
  def self.up
    add_column :sites, :chat_group_service_jid, :string
  end

  def self.down
    remove_column :sites, :chat_group_service_jid
  end
end
