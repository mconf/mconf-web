class PrivateMessages < ActiveRecord::Migration
  def self.up
     create_table "private_messages", :force => true do |t|
      t.integer  "sender_id"
      t.integer  "receiver_id"
      t.integer  "parent_id"
      t.boolean  "checked", :default => false
      t.string   "title"
      t.string   "body"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end

  def self.down
    drop_table "private_messages"
  end
end
