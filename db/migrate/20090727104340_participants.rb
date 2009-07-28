class Participants < ActiveRecord::Migration
  def self.up
     create_table "participants", :force => true do |t|
	t.string "email"
	t.integer "user_id"
	t.integer "event_id"
	t.datetime "created_at"
        t.datetime "updated_at"
	t.boolean "attend"
     end
  end

  def self.down
	drop_table "participants"
  end
end
