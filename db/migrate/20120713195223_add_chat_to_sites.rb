class AddChatToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :chat_enabled, :boolean, :default => false
  end
end
