class AddVccAuthenticationForChatServer < ActiveRecord::Migration
  def self.up
    add_column :sites, :vcc_user_for_chat_server, :string
    add_column :sites, :vcc_pass_for_chat_server, :string
  end

  def self.down
    remove_column :sites, :vcc_user_for_chat_server
    remove_column :sites, :vcc_pass_for_chat_server
  end
end
