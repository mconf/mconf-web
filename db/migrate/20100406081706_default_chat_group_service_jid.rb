SITE_CONFIG = YAML.load_file(File.join(Rails.root, "config", "site_conf.yml"))

class DefaultChatGroupServiceJid < ActiveRecord::Migration
  def self.up
    change_column :sites, :chat_group_service_jid, :string, :default => SITE_CONFIG["events_chat_service"]
    change_column :sites, :presence_domain, :string, :default => SITE_CONFIG["presence_domain"]
  end

  def self.down
    change_column :sites, :chat_group_service_jid, :string
    change_column :sites, :presence_domain, :string
  end
end
