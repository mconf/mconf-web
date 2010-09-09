class CreateChatLogs < ActiveRecord::Migration
  def self.up
    create_table :chat_logs do |t|
      t.integer  "event_id"
      t.string   "content"
      t.timestamps
    end
    
    change_column :chat_logs, :content, :longtext
    
    add_column :events, :chat_log_id, :integer
  end

  def self.down
    remove_column :events, :chat_log_id
    
    drop_table :chat_logs
  end
end
