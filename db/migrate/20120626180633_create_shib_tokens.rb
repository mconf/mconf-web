class CreateShibTokens < ActiveRecord::Migration
  def self.up
    create_table :shib_tokens do |t|
      t.integer  "user_id"
      t.string   "identifier"
      t.text     "data"
      t.timestamps
    end
  end

  def self.down
    drop_table :shib_tokens
  end
end
