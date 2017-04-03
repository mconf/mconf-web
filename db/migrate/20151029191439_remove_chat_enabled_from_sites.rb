class RemoveChatEnabledFromSites < ActiveRecord::Migration
  def change
    remove_column :sites, :chat_enabled, :string
  end
end
