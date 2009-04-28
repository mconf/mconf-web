# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090427101837) do

  create_table "attachments", :force => true do |t|
    t.string   "type"
    t.integer  "size"
    t.string   "content_type"
    t.string   "filename"
    t.integer  "height"
    t.integer  "width"
    t.integer  "parent_id"
    t.string   "thumbnail"
    t.integer  "db_file_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "post_id"
  end

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "domain_id"
    t.string   "domain_type"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categorizations", :force => true do |t|
    t.integer "category_id"
    t.integer "categorizable_id"
    t.string  "categorizable_type"
  end

  create_table "db_files", :force => true do |t|
    t.binary "data"
  end

  create_table "events", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "place"
    t.boolean  "isabel_event"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "machine_id"
    t.string   "colour",       :default => ""
    t.string   "repeat"
    t.integer  "at_job"
    t.integer  "parent_id"
    t.boolean  "character"
    t.boolean  "public_read"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "space_id"
    t.integer  "author_id"
    t.string   "author_type"
  end

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "space_id"
  end

  create_table "invitations", :force => true do |t|
    t.string   "email"
    t.integer  "stage_id"
    t.integer  "agent_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "stage_type"
    t.string   "agent_type"
    t.string   "acceptation_code"
    t.datetime "accepted_at"
  end

  create_table "logos", :force => true do |t|
    t.string   "type"
    t.integer  "size"
    t.string   "content_type"
    t.string   "filename"
    t.integer  "height"
    t.integer  "width"
    t.integer  "parent_id"
    t.string   "thumbnail"
    t.integer  "db_file_id"
    t.string   "logoable_type"
    t.integer  "logoable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "machines", :force => true do |t|
    t.string  "name",          :limit => 40, :default => "",    :null => false
    t.string  "nickname",      :limit => 40, :default => "",    :null => false
    t.boolean "public_access",               :default => false
  end

  create_table "machines_users", :id => false, :force => true do |t|
    t.integer "user_id",    :null => false
    t.integer "machine_id", :null => false
  end

  create_table "memberships", :force => true do |t|
    t.integer  "group_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "manager",    :default => false
  end

  create_table "open_id_associations", :force => true do |t|
    t.binary  "server_url"
    t.string  "handle"
    t.binary  "secret"
    t.integer "issued"
    t.integer "lifetime"
    t.string  "assoc_type"
  end

  create_table "open_id_nonces", :force => true do |t|
    t.string  "server_url", :default => "", :null => false
    t.integer "timestamp",                  :null => false
    t.string  "salt",       :default => "", :null => false
  end

  create_table "open_id_ownings", :force => true do |t|
    t.integer "agent_id"
    t.string  "agent_type"
    t.integer "uri_id"
  end

  create_table "open_id_trusts", :force => true do |t|
    t.integer "agent_id"
    t.string  "agent_type"
    t.integer "uri_id"
    t.boolean "local",      :default => false
  end

  create_table "performances", :force => true do |t|
    t.integer "agent_id"
    t.string  "agent_type"
    t.integer "role_id"
    t.integer "stage_id"
    t.string  "stage_type"
  end

  create_table "permissions", :force => true do |t|
    t.string "action"
    t.string "objective"
  end

  create_table "permissions_roles", :id => false, :force => true do |t|
    t.integer "permission_id"
    t.integer "role_id"
  end

  create_table "posts", :force => true do |t|
    t.string   "title"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "reader_id"
    t.integer  "space_id"
    t.integer  "author_id"
    t.string   "author_type"
    t.integer  "parent_id"
  end

  create_table "private_messages", :force => true do |t|
    t.integer  "sender_id"
    t.integer  "receiver_id"
    t.integer  "parent_id"
    t.boolean  "checked",             :default => false
    t.string   "title"
    t.string   "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "deleted_by_sender",   :default => false
    t.boolean  "deleted_by_receiver", :default => false
  end

  create_table "profiles", :force => true do |t|
    t.string "organization"
    t.string "phone"
    t.string "mobile"
    t.string "fax"
    t.string "address"
    t.string "city"
    t.string "zipcode"
    t.string "province"
    t.string "country"
    t.string "user_id"
  end

  create_table "readers", :force => true do |t|
    t.string   "url"
    t.integer  "space_id"
    t.datetime "last_updated"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string "name"
    t.string "stage_type"
  end

  create_table "simple_captcha_data", :force => true do |t|
    t.string   "key",        :limit => 40
    t.string   "value",      :limit => 6
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "singular_agents", :force => true do |t|
    t.string "type"
  end

  create_table "sites", :force => true do |t|
    t.string   "name",                          :default => "Virtual Conference Centre"
    t.text     "description"
    t.string   "domain",                        :default => "sir.dit.upm.es"
    t.string   "email",                         :default => "vcc@sir.dit.upm.es"
    t.string   "locale"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "ssl",                           :default => false
    t.boolean  "exception_notifications",       :default => false
    t.string   "exception_notifications_email"
  end

  create_table "spaces", :force => true do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.boolean  "deleted"
    t.boolean  "public",      :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
  end

  create_table "taggings", :force => true do |t|
    t.integer "tag_id",                        :null => false
    t.integer "taggable_id",                   :null => false
    t.string  "taggable_type", :default => "", :null => false
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type"], :name => "index_taggings_on_tag_id_and_taggable_id_and_taggable_type", :unique => true

  create_table "tags", :force => true do |t|
    t.string "name", :default => "", :null => false
  end

  add_index "tags", ["name"], :name => "index_tags_on_name", :unique => true

  create_table "uris", :force => true do |t|
    t.string "uri"
  end

  add_index "uris", ["uri"], :name => "index_uris_on_uri"

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.boolean  "superuser",                               :default => false
    t.boolean  "disabled",                                :default => false
    t.string   "reset_password_code",       :limit => 40
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
  end

end
