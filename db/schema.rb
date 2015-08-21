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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150729141849) do

  create_table "activities", force: true do |t|
    t.integer  "trackable_id"
    t.string   "trackable_type"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "key"
    t.text     "parameters"
    t.integer  "recipient_id"
    t.string   "recipient_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "notified"
  end

  add_index "activities", ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type", using: :btree
  add_index "activities", ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type", using: :btree
  add_index "activities", ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type", using: :btree

  create_table "attachments", force: true do |t|
    t.string   "type"
    t.integer  "size"
    t.string   "content_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "space_id"
    t.integer  "author_id"
    t.string   "author_type"
    t.string   "attachment"
  end

  create_table "bigbluebutton_meetings", force: true do |t|
    t.integer  "server_id"
    t.integer  "room_id"
    t.string   "meetingid"
    t.string   "name"
    t.datetime "start_time"
    t.boolean  "running",      default: false
    t.boolean  "recorded",     default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.string   "creator_name"
  end

  add_index "bigbluebutton_meetings", ["meetingid", "start_time"], name: "index_bigbluebutton_meetings_on_meetingid_and_start_time", unique: true, using: :btree

  create_table "bigbluebutton_metadata", force: true do |t|
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "name"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bigbluebutton_playback_formats", force: true do |t|
    t.integer  "recording_id"
    t.string   "url"
    t.integer  "length"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "playback_type_id"
  end

  create_table "bigbluebutton_playback_types", force: true do |t|
    t.string   "identifier"
    t.boolean  "visible",    default: false
    t.boolean  "default",    default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bigbluebutton_recordings", force: true do |t|
    t.integer  "server_id"
    t.integer  "room_id"
    t.string   "recordid"
    t.string   "meetingid"
    t.string   "name"
    t.boolean  "published",   default: false
    t.datetime "start_time"
    t.datetime "end_time"
    t.boolean  "available",   default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.integer  "meeting_id"
  end

  add_index "bigbluebutton_recordings", ["recordid"], name: "index_bigbluebutton_recordings_on_recordid", unique: true, using: :btree
  add_index "bigbluebutton_recordings", ["room_id"], name: "index_bigbluebutton_recordings_on_room_id", using: :btree

  create_table "bigbluebutton_room_options", force: true do |t|
    t.integer  "room_id"
    t.string   "default_layout"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "presenter_share_only"
    t.boolean  "auto_start_video"
    t.boolean  "auto_start_audio"
    t.string   "background"
  end

  add_index "bigbluebutton_room_options", ["room_id"], name: "index_bigbluebutton_room_options_on_room_id", using: :btree

  create_table "bigbluebutton_rooms", force: true do |t|
    t.integer  "server_id"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "meetingid"
    t.string   "name"
    t.string   "attendee_key"
    t.string   "moderator_key"
    t.string   "welcome_msg"
    t.string   "logout_url"
    t.string   "voice_bridge"
    t.string   "dial_number"
    t.integer  "max_participants"
    t.boolean  "private",                                             default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "external",                                            default: false
    t.string   "param"
    t.boolean  "record_meeting",                                      default: false
    t.integer  "duration",                                            default: 0
    t.string   "moderator_api_password"
    t.string   "attendee_api_password"
    t.decimal  "create_time",                precision: 14, scale: 0
    t.string   "moderator_only_message"
    t.boolean  "auto_start_recording",                                default: false
    t.boolean  "allow_start_stop_recording",                          default: true
  end

  add_index "bigbluebutton_rooms", ["meetingid"], name: "index_bigbluebutton_rooms_on_meetingid", unique: true, using: :btree
  add_index "bigbluebutton_rooms", ["server_id"], name: "index_bigbluebutton_rooms_on_server_id", using: :btree

  create_table "bigbluebutton_server_configs", force: true do |t|
    t.integer  "server_id"
    t.text     "available_layouts"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bigbluebutton_servers", force: true do |t|
    t.string   "name"
    t.string   "url"
    t.string   "salt"
    t.string   "version"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "param"
  end

  create_table "db_files", force: true do |t|
    t.binary "data"
  end

  create_table "invitations", force: true do |t|
    t.integer  "target_id"
    t.string   "target_type"
    t.integer  "sender_id"
    t.integer  "recipient_id"
    t.string   "recipient_email"
    t.string   "type"
    t.string   "title"
    t.text     "description"
    t.string   "url"
    t.datetime "starts_on"
    t.datetime "ends_on"
    t.boolean  "ready",           default: false
    t.boolean  "sent",            default: false
    t.boolean  "result",          default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "invitations", ["target_id", "target_type"], name: "index_invitations_on_target_id_and_target_type", using: :btree

  create_table "join_requests", force: true do |t|
    t.string   "request_type"
    t.integer  "candidate_id"
    t.integer  "introducer_id"
    t.integer  "group_id"
    t.string   "group_type"
    t.string   "comment"
    t.integer  "role_id"
    t.string   "email"
    t.boolean  "accepted"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "processed_at"
    t.string   "secret_token"
  end

  create_table "ldap_tokens", force: true do |t|
    t.integer  "user_id"
    t.string   "identifier"
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ldap_tokens", ["identifier"], name: "index_ldap_tokens_on_identifier", unique: true, using: :btree
  add_index "ldap_tokens", ["user_id"], name: "index_ldap_tokens_on_user_id", unique: true, using: :btree

  create_table "mweb_events_events", force: true do |t|
    t.string   "name"
    t.text     "summary"
    t.text     "description"
    t.string   "social_networks"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.datetime "start_on"
    t.datetime "end_on"
    t.string   "time_zone"
    t.string   "location"
    t.string   "address"
    t.float    "latitude",        limit: 24
    t.float    "longitude",       limit: 24
    t.string   "permalink"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mweb_events_events", ["permalink"], name: "index_mweb_events_events_on_permalink", using: :btree

  create_table "mweb_events_participants", force: true do |t|
    t.integer  "owner_id"
    t.string   "owner_type"
    t.integer  "event_id"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "news", force: true do |t|
    t.string   "title"
    t.text     "text"
    t.integer  "space_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "participant_confirmations", force: true do |t|
    t.string   "token"
    t.integer  "participant_id"
    t.datetime "confirmed_at"
    t.datetime "email_sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "permissions", force: true do |t|
    t.integer  "user_id",      null: false
    t.integer  "subject_id",   null: false
    t.string   "subject_type", null: false
    t.integer  "role_id",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "posts", force: true do |t|
    t.string   "title"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "reader_id"
    t.integer  "space_id"
    t.integer  "author_id"
    t.string   "author_type"
    t.integer  "parent_id"
    t.boolean  "spam",        default: false
  end

  create_table "private_messages", force: true do |t|
    t.integer  "sender_id"
    t.integer  "receiver_id"
    t.integer  "parent_id"
    t.boolean  "checked",             default: false
    t.string   "title"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "deleted_by_sender",   default: false
    t.boolean  "deleted_by_receiver", default: false
  end

  create_table "profiles", force: true do |t|
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
    t.string  "prefix_key",   default: ""
    t.text    "description"
    t.string  "url"
    t.string  "skype"
    t.string  "im"
    t.integer "visibility",   default: 3
    t.string  "full_name"
    t.string  "logo_image"
  end

  create_table "roles", force: true do |t|
    t.string "name"
    t.string "stage_type"
  end

  create_table "shib_tokens", force: true do |t|
    t.integer  "user_id"
    t.string   "identifier"
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "shib_tokens", ["identifier"], name: "index_shib_tokens_on_identifier", unique: true, using: :btree
  add_index "shib_tokens", ["user_id"], name: "index_shib_tokens_on_user_id", unique: true, using: :btree

  create_table "sites", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "domain"
    t.string   "smtp_login"
    t.string   "locale"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "ssl",                            default: false
    t.boolean  "exception_notifications",        default: false
    t.string   "exception_notifications_email"
    t.text     "signature"
    t.string   "presence_domain"
    t.string   "feedback_url"
    t.boolean  "shib_enabled",                   default: false
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
    t.boolean  "chat_enabled",                   default: false
    t.string   "xmpp_server"
    t.text     "shib_env_variables"
    t.string   "shib_login_field"
    t.string   "timezone",                       default: "UTC"
    t.string   "external_help"
    t.boolean  "webconf_auto_record",            default: false
    t.boolean  "ldap_enabled"
    t.string   "ldap_host"
    t.integer  "ldap_port"
    t.string   "ldap_user"
    t.string   "ldap_user_password"
    t.string   "ldap_user_treebase"
    t.string   "ldap_username_field"
    t.string   "ldap_email_field"
    t.string   "ldap_name_field"
    t.boolean  "require_registration_approval",  default: false,                  null: false
    t.boolean  "events_enabled",                 default: false
    t.boolean  "registration_enabled",           default: true,                   null: false
    t.string   "shib_principal_name_field"
    t.string   "ldap_filter"
    t.boolean  "shib_always_new_account",        default: false
    t.boolean  "local_auth_enabled",             default: true
    t.string   "visible_locales",                default: "---\n- en\n- pt-br\n"
    t.string   "room_dial_number_pattern"
  end

  create_table "spaces", force: true do |t|
    t.string   "name"
    t.boolean  "deleted"
    t.boolean  "public",      default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.string   "permalink"
    t.boolean  "disabled",    default: false
    t.boolean  "repository",  default: false
    t.string   "logo_image"
  end

  create_table "users", force: true do |t|
    t.string   "username"
    t.string   "email",                             default: "",    null: false
    t.string   "encrypted_password",                default: "",    null: false
    t.string   "password_salt",          limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "superuser",                         default: false
    t.boolean  "disabled",                          default: false
    t.datetime "confirmed_at"
    t.string   "timezone"
    t.boolean  "expanded_post",                     default: false
    t.string   "locale"
    t.integer  "receive_digest",                    default: 0
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                     default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.boolean  "can_record"
    t.boolean  "approved",                          default: false, null: false
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
