class Init < ActiveRecord::Migration
  def self.up
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

    create_table "entries", :force => true do |t|
      t.string   "title"
      t.text     "description"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "container_id"
      t.string   "container_type"
      t.integer  "agent_id"
      t.string   "agent_type"
      t.integer  "content_id"
      t.string   "content_type"
      t.integer  "parent_id"
      t.string   "parent_type"
      t.boolean  "public_read"
      t.boolean  "public_write"
    end

    create_table :events, :force => true do |t|
      t.string   "name"
      t.string   "description"
      t.string   "place"
      t.boolean  "isabel_event"
      t.datetime "start_date"
      t.datetime "end_date"
      t.integer  "machine_id"
      t.string   "colour" , :default => ""
      t.string   "repeat"
      t.integer  "at_job"
      t.integer  "parent_id"
      t.boolean  "character"
      t.boolean  "public_read"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "groups", :force => true do |t|
      t.string   "name"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "space_id"
    end

    create_table "groups_users", :id => false, :force => true do |t|
      t.integer  "group_id"
      t.integer  "user_id"
      t.datetime "created_at"
      t.datetime "updated_at"
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

    create_table "logotypes", :force => true do |t|
      t.string   "type"
      t.integer  "size"
      t.string   "content_type"
      t.string   "filename"
      t.integer  "height"
      t.integer  "width"
      t.integer  "parent_id"
      t.string   "thumbnail"
      t.integer  "db_file_id"
      t.string   "logotypable_type"
      t.integer  "logotypable_id"
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
    end

    create_table "profiles", :force => true do |t|
      t.string "name"
      t.string "lastname"
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
      t.string  "name"
      t.string  "stage_type"
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
      t.string   "name"
      t.text     "description"
      t.string   "domain"
      t.string   "email"
      t.string   "locale"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "ssl",         :default => false
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

  def self.down
    drop_table "attachments"
    drop_table "categories"
    drop_table "categorizations"
    drop_table "db_files"
    drop_table "entries"
    drop_table "events"
    drop_table "groups"
    drop_table "groups_users"
    drop_table "invitations"
    drop_table "logotypes"
    drop_table "machines"
    drop_table "machines_users"
    drop_table "open_id_associations"
    drop_table "open_id_nonces"
    drop_table "open_id_ownings"
    drop_table "open_id_trusts"
    drop_table "performances"
    drop_table "permissions"
    drop_table "permissions_roles"
    drop_table "posts"
    drop_table "profiles"
    drop_table "readers"
    drop_table "roles"
    drop_table "simple_captcha_data"
    drop_table "singular_agents"
    drop_table "sites"
    drop_table "spaces"
    drop_table "taggings"
    drop_table "tags"
    drop_table "uris"
    drop_table "users"
  end
end
