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

ActiveRecord::Schema.define(:version => 20082030101012) do

  create_table "anonymous_agents", :force => true do |t|
  end

  create_table "articles", :force => true do |t|
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
  end

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
    t.integer  "container_id"
    t.string   "container_type"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categorizations", :force => true do |t|
    t.integer "category_id"
    t.integer "entry_id"
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

  create_table "event_datetimes", :force => true do |t|
    t.integer  "event_id",   :null => false
    t.datetime "start_date", :null => false
    t.datetime "end_date",   :null => false
    t.integer  "at_job"
  end

  create_table "events", :force => true do |t|
    t.string "name",        :limit => 40, :default => "", :null => false
    t.string "password",    :limit => 40, :default => "", :null => false
    t.string "service",     :limit => 40, :default => "", :null => false
    t.string "quality",     :limit => 8,  :default => "", :null => false
    t.text   "description"
    t.string "uri",         :limit => 80, :default => "", :null => false
  end

  create_table "events_users", :id => false, :force => true do |t|
    t.integer "user_id",  :null => false
    t.integer "event_id", :null => false
  end

  create_table "globalize_countries", :force => true do |t|
    t.string "code",                   :limit => 2
    t.string "english_name"
    t.string "date_format"
    t.string "currency_format"
    t.string "currency_code",          :limit => 3
    t.string "thousands_sep",          :limit => 2
    t.string "decimal_sep",            :limit => 2
    t.string "currency_decimal_sep",   :limit => 2
    t.string "number_grouping_scheme"
  end

  add_index "globalize_countries", ["code"], :name => "index_globalize_countries_on_code"

  create_table "globalize_languages", :force => true do |t|
    t.string  "iso_639_1",             :limit => 2
    t.string  "iso_639_2",             :limit => 3
    t.string  "iso_639_3",             :limit => 3
    t.string  "rfc_3066"
    t.string  "english_name"
    t.string  "english_name_locale"
    t.string  "english_name_modifier"
    t.string  "native_name"
    t.string  "native_name_locale"
    t.string  "native_name_modifier"
    t.boolean "macro_language"
    t.string  "direction"
    t.string  "pluralization"
    t.string  "scope",                 :limit => 1
  end

  add_index "globalize_languages", ["iso_639_1"], :name => "index_globalize_languages_on_iso_639_1"
  add_index "globalize_languages", ["iso_639_2"], :name => "index_globalize_languages_on_iso_639_2"
  add_index "globalize_languages", ["iso_639_3"], :name => "index_globalize_languages_on_iso_639_3"
  add_index "globalize_languages", ["rfc_3066"], :name => "index_globalize_languages_on_rfc_3066"

  create_table "globalize_translations", :force => true do |t|
    t.string  "type"
    t.string  "tr_key"
    t.string  "table_name"
    t.integer "item_id"
    t.string  "facet"
    t.boolean "built_in",            :default => true
    t.integer "language_id"
    t.integer "pluralization_index"
    t.text    "text"
    t.string  "namespace"
  end

  add_index "globalize_translations", ["tr_key", "language_id"], :name => "index_globalize_translations_on_tr_key_and_language_id"
  add_index "globalize_translations", ["table_name", "item_id", "language_id"], :name => "globalize_translations_table_name_and_item_and_language"

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
    t.integer  "space_id"
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
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

  create_table "participants", :force => true do |t|
    t.integer "event_id",                                              :null => false
    t.integer "machine_id",                                            :null => false
    t.integer "machine_id_connected_to",                               :null => false
    t.string  "role",                    :limit => 40, :default => "", :null => false
    t.integer "fec",                                   :default => 0,  :null => false
    t.integer "radiate_multicast",                     :default => 0,  :null => false
    t.text    "description"
  end

  create_table "performances", :force => true do |t|
    t.integer "agent_id"
    t.string  "agent_type"
    t.integer "role_id"
    t.integer "container_id"
    t.string  "container_type"
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

  create_table "roles", :force => true do |t|
    t.string  "name"
    t.boolean "create_entries"
    t.boolean "read_entries"
    t.boolean "update_entries"
    t.boolean "delete_entries"
    t.boolean "create_performances"
    t.boolean "read_performances"
    t.boolean "update_performances"
    t.boolean "delete_performances"
    t.boolean "manage_events"
    t.boolean "admin"
    t.string  "type"
  end

  create_table "simple_captcha_data", :force => true do |t|
    t.string   "key",        :limit => 40
    t.string   "value",      :limit => 6
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sites", :force => true do |t|
    t.string   "name",        :default => "Virtual Conference Centre"
    t.text     "description"
    t.string   "domain",      :default => "sir.dit.upm.es"
    t.string   "email",       :default => "vcc@sir.dit.upm.es"
    t.string   "locale"
    t.datetime "created_at"
    t.datetime "updated_at"
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
