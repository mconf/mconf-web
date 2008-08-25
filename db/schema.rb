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

ActiveRecord::Schema.define(:version => 40) do

  create_table "cms_attachment_fus", :force => true do |t|
    t.string   "type"
    t.integer  "size",         :limit => 11
    t.string   "content_type"
    t.string   "filename"
    t.integer  "height",       :limit => 11
    t.integer  "width",        :limit => 11
    t.integer  "parent_id",    :limit => 11
    t.string   "thumbnail"
    t.integer  "db_file_id",   :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cms_categories", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "container_id",   :limit => 11
    t.string   "container_type"
    t.integer  "parent_id",      :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cms_categorizations", :force => true do |t|
    t.integer "category_id", :limit => 11
    t.integer "post_id",     :limit => 11
  end

  create_table "cms_performances", :force => true do |t|
    t.integer "agent_id",       :limit => 11
    t.string  "agent_type"
    t.integer "role_id",        :limit => 11
    t.integer "container_id",   :limit => 11
    t.string  "container_type"
  end

  create_table "cms_posts", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "container_id",   :limit => 11
    t.string   "container_type"
    t.integer  "agent_id",       :limit => 11
    t.string   "agent_type"
    t.integer  "content_id",     :limit => 11
    t.string   "content_type"
    t.integer  "parent_id",      :limit => 11
    t.string   "parent_type"
    t.boolean  "public_read"
    t.boolean  "public_write"
  end

  create_table "cms_roles", :force => true do |t|
    t.string  "name"
    t.boolean "create_posts"
    t.boolean "read_posts"
    t.boolean "update_posts"
    t.boolean "delete_posts"
    t.boolean "create_performances"
    t.boolean "read_performances"
    t.boolean "update_performances"
    t.boolean "delete_performances"
    t.boolean "manage_events"
    t.boolean "admin"
    t.string  "type"
  end

  create_table "cms_texts", :force => true do |t|
    t.string   "type"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cms_uris", :force => true do |t|
    t.string "uri"
  end

  add_index "cms_uris", ["uri"], :name => "index_cms_uris_on_uri"

  create_table "db_files", :force => true do |t|
    t.binary "data"
  end

  create_table "event_datetimes", :force => true do |t|
    t.integer  "event_id",   :limit => 11, :null => false
    t.datetime "start_date",               :null => false
    t.datetime "end_date",                 :null => false
    t.integer  "at_job",     :limit => 11
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
    t.integer "user_id",  :limit => 11, :null => false
    t.integer "event_id", :limit => 11, :null => false
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
    t.integer "item_id",             :limit => 11
    t.string  "facet"
    t.boolean "built_in",                          :default => true
    t.integer "language_id",         :limit => 11
    t.integer "pluralization_index", :limit => 11
    t.text    "text"
    t.string  "namespace"
  end

  add_index "globalize_translations", ["tr_key", "language_id"], :name => "index_globalize_translations_on_tr_key_and_language_id"
  add_index "globalize_translations", ["table_name", "item_id", "language_id"], :name => "globalize_translations_table_name_and_item_and_language"

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "space_id",   :limit => 11
  end

  create_table "groups_users", :id => false, :force => true do |t|
    t.integer "group_id", :limit => 11
    t.integer "user_id",  :limit => 11
  end

  create_table "invitations", :force => true do |t|
    t.string   "email"
    t.integer  "space_id",   :limit => 11
    t.integer  "user_id",    :limit => 11
    t.integer  "role_id",    :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "machines", :force => true do |t|
    t.string "name",     :limit => 40, :default => "", :null => false
    t.string "nickname", :limit => 40, :default => "", :null => false
  end

  create_table "machines_users", :id => false, :force => true do |t|
    t.integer "user_id",    :limit => 11, :null => false
    t.integer "machine_id", :limit => 11, :null => false
  end

  create_table "open_id_associations", :force => true do |t|
    t.binary  "server_url"
    t.string  "handle"
    t.binary  "secret"
    t.integer "issued",     :limit => 11
    t.integer "lifetime",   :limit => 11
    t.string  "assoc_type"
  end

  create_table "open_id_nonces", :force => true do |t|
    t.string  "server_url",               :default => "", :null => false
    t.integer "timestamp",  :limit => 11,                 :null => false
    t.string  "salt",                     :default => "", :null => false
  end

  create_table "open_id_ownings", :force => true do |t|
    t.integer "agent_id",   :limit => 11
    t.string  "agent_type"
    t.integer "uri_id",     :limit => 11
  end

  create_table "participants", :force => true do |t|
    t.integer "event_id",                :limit => 11,                 :null => false
    t.integer "machine_id",              :limit => 11,                 :null => false
    t.integer "machine_id_connected_to", :limit => 11,                 :null => false
    t.string  "role",                    :limit => 40, :default => "", :null => false
    t.integer "fec",                     :limit => 2,  :default => 0,  :null => false
    t.integer "radiate_multicast",       :limit => 1,  :default => 0,  :null => false
    t.text    "description"
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

  create_table "simple_captcha_data", :force => true do |t|
    t.string   "key",        :limit => 40
    t.string   "value",      :limit => 6
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "spaces", :force => true do |t|
    t.string   "name"
    t.integer  "parent_id",   :limit => 11
    t.boolean  "deleted"
    t.boolean  "public",                    :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
  end

  create_table "taggings", :force => true do |t|
    t.integer "tag_id",        :limit => 11,                 :null => false
    t.integer "taggable_id",   :limit => 11,                 :null => false
    t.string  "taggable_type",               :default => "", :null => false
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type"], :name => "index_taggings_on_tag_id_and_taggable_id_and_taggable_type", :unique => true

  create_table "tags", :force => true do |t|
    t.string "name", :default => "", :null => false
  end

  add_index "tags", ["name"], :name => "index_tags_on_name", :unique => true

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
    t.string   "email2"
    t.string   "email3"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
  end

end
