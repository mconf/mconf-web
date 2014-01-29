# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140120160728) do

  create_table "activities", :force => true do |t|
    t.integer  "trackable_id"
    t.string   "trackable_type"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "key"
    t.text     "parameters"
    t.integer  "recipient_id"
    t.string   "recipient_type"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "activities", ["owner_id", "owner_type"], :name => "index_activities_on_owner_id_and_owner_type"
  add_index "activities", ["recipient_id", "recipient_type"], :name => "index_activities_on_recipient_id_and_recipient_type"
  add_index "activities", ["trackable_id", "trackable_type"], :name => "index_activities_on_trackable_id_and_trackable_type"

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
    t.integer  "space_id"
    t.integer  "event_id"
    t.integer  "author_id"
    t.string   "author_type"
    t.integer  "version_child_id"
    t.integer  "version_family_id"
  end

  add_index "attachments", ["version_child_id"], :name => "index_attachments_on_version_child_id"
  add_index "attachments", ["version_family_id"], :name => "index_attachments_on_version_family_id"

  create_table "bigbluebutton_meetings", :force => true do |t|
    t.integer  "server_id"
    t.integer  "room_id"
    t.string   "meetingid"
    t.string   "name"
    t.datetime "start_time"
    t.boolean  "running",    :default => false
    t.boolean  "record",     :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "bigbluebutton_meetings", ["meetingid", "start_time"], :name => "index_bigbluebutton_meetings_on_meetingid_and_start_time", :unique => true

  create_table "bigbluebutton_metadata", :force => true do |t|
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "name"
    t.text     "content"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "bigbluebutton_playback_formats", :force => true do |t|
    t.integer  "recording_id"
    t.string   "format_type"
    t.string   "url"
    t.integer  "length"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "bigbluebutton_recordings", :force => true do |t|
    t.integer  "server_id"
    t.integer  "room_id"
    t.string   "recordid"
    t.string   "meetingid"
    t.string   "name"
    t.boolean  "published",   :default => false
    t.datetime "start_time"
    t.datetime "end_time"
    t.boolean  "available",   :default => true
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.string   "description"
    t.integer  "meeting_id"
  end

  add_index "bigbluebutton_recordings", ["recordid"], :name => "index_bigbluebutton_recordings_on_recordid", :unique => true
  add_index "bigbluebutton_recordings", ["room_id"], :name => "index_bigbluebutton_recordings_on_room_id"

  create_table "bigbluebutton_room_options", :force => true do |t|
    t.integer  "room_id"
    t.string   "default_layout"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "bigbluebutton_room_options", ["room_id"], :name => "index_bigbluebutton_room_options_on_room_id"

  create_table "bigbluebutton_rooms", :force => true do |t|
    t.integer  "server_id"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "meetingid"
    t.string   "name"
    t.string   "attendee_password"
    t.string   "moderator_password"
    t.string   "welcome_msg"
    t.string   "logout_url"
    t.string   "voice_bridge"
    t.string   "dial_number"
    t.integer  "max_participants"
    t.boolean  "private",            :default => false
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.boolean  "external",           :default => false
    t.string   "param"
    t.boolean  "record",             :default => false
    t.integer  "duration",           :default => 0
  end

  add_index "bigbluebutton_rooms", ["meetingid"], :name => "index_bigbluebutton_rooms_on_meetingid", :unique => true
  add_index "bigbluebutton_rooms", ["server_id"], :name => "index_bigbluebutton_rooms_on_server_id"
  add_index "bigbluebutton_rooms", ["voice_bridge"], :name => "index_bigbluebutton_rooms_on_voice_bridge", :unique => true

  create_table "bigbluebutton_servers", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.string   "salt"
    t.string   "version"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "param"
  end

  create_table "db_files", :force => true do |t|
    t.binary "data"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.string   "queue"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "events", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "place"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "space_id"
    t.integer  "author_id"
    t.string   "author_type"
    t.boolean  "spam",                    :default => false
    t.text     "notes"
    t.text     "location"
    t.string   "permalink"
    t.text     "other_participation_url"
  end

  create_table "join_requests", :force => true do |t|
    t.string   "request_type"
    t.integer  "candidate_id"
    t.integer  "introducer_id"
    t.integer  "group_id"
    t.string   "group_type"
    t.string   "comment"
    t.integer  "role_id"
    t.string   "email"
    t.boolean  "accepted"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.datetime "processed_at"
  end

  create_table "ldap_tokens", :force => true do |t|
    t.integer  "user_id"
    t.string   "identifier"
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "ldap_tokens", ["identifier"], :name => "index_ldap_tokens_on_identifier", :unique => true
  add_index "ldap_tokens", ["user_id"], :name => "index_ldap_tokens_on_user_id", :unique => true

  create_table "news", :force => true do |t|
    t.string   "title"
    t.text     "text"
    t.integer  "space_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "participants", :force => true do |t|
    t.string   "email"
    t.integer  "user_id"
    t.integer  "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "attend"
  end

  create_table "permissions", :force => true do |t|
    t.integer  "user_id",      :null => false
    t.integer  "subject_id",   :null => false
    t.string   "subject_type", :null => false
    t.integer  "role_id",      :null => false
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "post_attachments", :force => true do |t|
    t.integer "post_id"
    t.integer "attachment_id"
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
    t.integer  "event_id"
    t.boolean  "spam",        :default => false
  end

  create_table "private_messages", :force => true do |t|
    t.integer  "sender_id"
    t.integer  "receiver_id"
    t.integer  "parent_id"
    t.boolean  "checked",             :default => false
    t.string   "title"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "deleted_by_sender",   :default => false
    t.boolean  "deleted_by_receiver", :default => false
  end

  create_table "profiles", :force => true do |t|
    t.string  "organization"
    t.string  "phone"
    t.string  "mobile"
    t.string  "fax"
    t.string  "address"
    t.string  "city"
    t.string  "zipcode"
    t.string  "province"
    t.string  "country"
    t.integer "user_id"
    t.string  "prefix_key",   :default => ""
    t.text    "description"
    t.string  "url"
    t.string  "skype"
    t.string  "im"
    t.integer "visibility",   :default => 3
    t.string  "full_name"
    t.string  "logo_image"
  end

  create_table "roles", :force => true do |t|
    t.string "name"
    t.string "stage_type"
  end

  create_table "shib_tokens", :force => true do |t|
    t.integer  "user_id"
    t.string   "identifier"
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "shib_tokens", ["identifier"], :name => "index_shib_tokens_on_identifier", :unique => true
  add_index "shib_tokens", ["user_id"], :name => "index_shib_tokens_on_user_id", :unique => true

  create_table "simple_captcha_data", :force => true do |t|
    t.string   "key",        :limit => 40
    t.string   "value",      :limit => 6
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "simple_captcha_data", ["key"], :name => "idx_key"

  create_table "sites", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "domain"
    t.string   "smtp_login"
    t.string   "locale"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "ssl",                            :default => false
    t.boolean  "exception_notifications",        :default => false
    t.string   "exception_notifications_email"
    t.text     "signature"
    t.string   "presence_domain"
    t.string   "feedback_url"
    t.boolean  "shib_enabled",                   :default => false
    t.string   "shib_name_field"
    t.string   "shib_email_field"
    t.string   "exception_notifications_prefix"
    t.string   "smtp_password"
    t.string   "analytics_code"
    t.boolean  "smtp_auto_tls"
    t.string   "smtp_server"
    t.integer  "smtp_port"
    t.boolean  "smtp_use_tls"
    t.string   "smtp_domain"
    t.string   "smtp_auth_type"
    t.string   "smtp_sender"
    t.boolean  "chat_enabled",                   :default => false
    t.string   "xmpp_server"
    t.text     "shib_env_variables"
    t.string   "shib_login_field"
    t.string   "timezone",                       :default => "UTC"
    t.string   "external_help"
    t.boolean  "webconf_auto_record",            :default => false
    t.boolean  "ldap_enabled"
    t.string   "ldap_host"
    t.integer  "ldap_port"
    t.string   "ldap_user"
    t.string   "ldap_user_password"
    t.string   "ldap_user_treebase"
    t.string   "ldap_username_field"
    t.string   "ldap_email_field"
    t.string   "ldap_name_field"
    t.boolean  "require_registration_approval",  :default => false, :null => false
  end

  create_table "spaces", :force => true do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.boolean  "deleted"
    t.boolean  "public",      :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.string   "permalink"
    t.boolean  "disabled",    :default => false
    t.boolean  "repository",  :default => false
    t.string   "logo_image"
  end

  create_table "statistics", :force => true do |t|
    t.string   "url"
    t.integer  "unique_pageviews"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "taggings", :force => true do |t|
    t.integer "tag_id",                        :null => false
    t.integer "taggable_id",                   :null => false
    t.string  "taggable_type", :default => "", :null => false
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type"], :name => "index_taggings_on_tag_id_and_taggable_id_and_taggable_type", :unique => true

  create_table "tags", :force => true do |t|
    t.string  "name",           :default => "", :null => false
    t.integer "container_id"
    t.string  "container_type"
    t.integer "taggings_count", :default => 0
  end

  add_index "tags", ["name", "container_id", "container_type"], :name => "index_tags_on_name_and_container_id_and_container_type"

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "email",                                :default => "",    :null => false
    t.string   "encrypted_password",                   :default => "",    :null => false
    t.string   "password_salt",          :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "superuser",                            :default => false
    t.boolean  "disabled",                             :default => false
    t.datetime "confirmed_at"
    t.string   "timezone",                             :default => "UTC"
    t.boolean  "expanded_post",                        :default => false
    t.integer  "notification",                         :default => 1
    t.string   "locale"
    t.integer  "receive_digest",                       :default => 0
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                        :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.boolean  "can_record"
    t.boolean  "approved",                             :default => false, :null => false
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
