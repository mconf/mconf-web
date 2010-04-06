class DefaultChatGroupServiceJid < ActiveRecord::Migration
  def self.up
    change_column :sites, :chat_group_service_jid, :string, :default => "events.sir.dit.upm.es"
    change_column :sites, :presence_domain, :string, :default => "sir.dit.upm.es "
  end

  def self.down
    change_column :sites, :chat_group_service_jid, :string
    change_column :sites, :presence_domain, :string
  end
end
