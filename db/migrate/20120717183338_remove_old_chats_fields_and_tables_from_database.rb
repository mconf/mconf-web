class RemoveOldChatsFieldsAndTablesFromDatabase < ActiveRecord::Migration
  def up
    remove_column :sites, :chat_group_service_jid
    remove_column :users, :chat_activation
    remove_column :sites, :vcc_user_for_chat_server
    remove_column :sites, :vcc_pass_for_chat_server
    remove_column :events, :chat_log_id

    drop_table :chat_logs
  end

  def down
    create_table :chat_logs do |t|
      t.integer  "event_id"
      t.string   "content"
      t.timestamps
    end

    change_column :chat_logs, :content, :longtext

    add_column :sites, :chat_group_service_jid, :string
    add_column :users, :chat_activation, :boolean, :default => true

    User.all.each do |u|
      u.update_attribute :chat_activation, true
    end

    add_column :sites, :vcc_user_for_chat_server, :string
    add_column :sites, :vcc_pass_for_chat_server, :string
    add_column :events, :chat_log_id, :integer
  end
end
