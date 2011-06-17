class DefaultChatGroupServiceJid < ActiveRecord::Migration
  def self.up
    change_column :sites, :chat_group_service_jid, :string
    change_column :sites, :presence_domain, :string
  end

  def self.down
    change_column :sites, :chat_group_service_jid, :string
    change_column :sites, :presence_domain, :string
  end
end
