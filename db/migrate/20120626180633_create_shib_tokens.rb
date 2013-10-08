class CreateShibTokens < ActiveRecord::Migration
  def self.up
    create_table :shib_tokens do |t|
      t.integer  "user_id"
      t.string   "identifier"
      t.text     "data"
      t.timestamps
    end
    add_index :shib_tokens, :user_id, :unique => true
    add_index :shib_tokens, :identifier, :unique => true
  end

  def self.down
    drop_table :shib_tokens
  end
end
