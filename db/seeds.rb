# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# Make sure the config file exists and load it
CONFIG_FILE = File.join(::Rails.root, "config", "setup_conf.yml")
DEFAULT_CONFIG_FILE = File.join(::Rails.root, "config", "setup_conf.yml.example")
unless File.exists? DEFAULT_CONFIG_FILE
  puts
  puts "ERROR"
  puts "The default configuration file does not exists! Make sure your repository is up to date."
  puts "Path: #{DEFAULT_CONFIG_FILE}"
  puts
  exit
end

# load the default values and the user configured values
default_config = YAML.load_file(DEFAULT_CONFIG_FILE)
config = default_config["default"]

# the user customized config file
if File.exists?(CONFIG_FILE)
  user_config = YAML.load_file(CONFIG_FILE)
  # use the default config but override any value also set in the user config
  config.deep_merge!(user_config["default"]) unless user_config["default"].nil?
  # merge the user configs for the current environment
  config.deep_merge!(user_config[Rails.env]) unless user_config[Rails.env].nil?
end

puts "* Create the default site"
puts "  name: #{config["site_name"]}"
puts "  description: #{config["site_description"]}"
puts "  email: #{config["site_email"]}"
puts "  email_password: #{config["site_email_password"].gsub(/./, "*") unless config["site_email_password"].blank?}"
puts "  locale: #{config["site_locale"]}"
puts "  domain: #{config["site_domain"]}"
puts "  signature: #{config["site_signature"]}"
puts "  feedback_url: #{config["site_feedback_url"]}"
puts "  analytics_code: #{config["site_analytics_code"]}"
puts "  ssl: #{config["site_ssl"] == "true"}"
puts "  exception_notifications: #{config["site_exception_notifications"] == "true"}"
puts "  exception_notifications_recipients: #{config["site_exception_notifications_recipients"]}"
puts "  exception_notifications_prefix: #{config["site_exception_notifications_prefix"]}"
puts "  shib_enabled: #{config["site_shibboleth"] == "true"}"
puts "  shib_email_field: #{config["site_shibboleth_email_field"]}"
puts "  shib_name_field: #{config["site_shibboleth_name_field"]}"
u = Site.create :name => config["site_name"],
                :description => config["site_description"],
                :email => config["site_email"],
                :email_password => config["site_email_password"],
                :locale => config["site_locale"],
                :domain => config["site_domain"],
                :signature => config["site_signature"],
                :feedback_url => config["site_feedback_url"],
                :analytics_code => config["analytics_code"],
                :ssl => config["site_ssl"] == "true",
                :exception_notifications => config["site_exception_notifications"] == "true",
                :exception_notifications_email => config["site_exception_notifications_recipients"],
                :exception_notifications_prefix => config["site_exception_notifications_prefix"],
                :shib_enabled => config["site_shibboleth"] == "true",
                :shib_email_field => config["site_shibboleth_email_field"],
                :shib_name_field => config["site_shibboleth_name_field"]


puts "* Create Permissions"

# Permissions without objective
%w( read update delete translate ).each do |action|
  Permission.find_or_create_by_action_and_objective action, nil
end

# Permissions applied to Content and Performance
%w( create read update delete ).each do |action|
  %w( content performance ).each do |objective|
    Permission.find_or_create_by_action_and_objective action, objective
  end
end

Permission.find_or_create_by_action_and_objective "update", "attachment"

# Permission applied to Group
Permission.find_or_create_by_action_and_objective "manage", "group"
# Permission to start an event
Permission.find_or_create_by_action_and_objective "start", "event"


puts "* Create Roles"

translator_role = Role.find_or_create_by_name_and_stage_type "Translator", "Site"
translator_role.permissions << Permission.find_by_action_and_objective('translate', nil)

organizer_role = Role.find_or_create_by_name_and_stage_type "Organizer", "Event"
organizer_role.permissions << Permission.find_by_action_and_objective('read', nil)
organizer_role.permissions << Permission.find_by_action_and_objective('update', nil)
organizer_role.permissions << Permission.find_by_action_and_objective('create', 'content')
organizer_role.permissions << Permission.find_by_action_and_objective('read',   'content')
organizer_role.permissions << Permission.find_by_action_and_objective('update', 'content')
organizer_role.permissions << Permission.find_by_action_and_objective('delete', 'content')
organizer_role.permissions << Permission.find_by_action_and_objective('start', 'event')

invitedevent_role = Role.find_or_create_by_name_and_stage_type "Invitedevent", "Event"
invitedevent_role.permissions << Permission.find_by_action_and_objective('read', nil)

speaker_role = Role.find_or_create_by_name_and_stage_type "Speaker", "AgendaEntry"
speaker_role.permissions << Permission.find_by_action_and_objective('read', nil)
speaker_role.permissions << Permission.find_by_action_and_objective('update', nil)

admin_role = Role.find_or_create_by_name_and_stage_type "Admin", "Space"
admin_role.permissions << Permission.find_by_action_and_objective('read',   nil)
admin_role.permissions << Permission.find_by_action_and_objective('update', nil)
admin_role.permissions << Permission.find_by_action_and_objective('delete', nil)
admin_role.permissions << Permission.find_by_action_and_objective('create', 'content')
admin_role.permissions << Permission.find_by_action_and_objective('read',   'content')
admin_role.permissions << Permission.find_by_action_and_objective('update', 'content')
admin_role.permissions << Permission.find_by_action_and_objective('delete', 'content')
admin_role.permissions << Permission.find_by_action_and_objective('create', 'performance')
admin_role.permissions << Permission.find_by_action_and_objective('read',   'performance')
admin_role.permissions << Permission.find_by_action_and_objective('update', 'performance')
admin_role.permissions << Permission.find_by_action_and_objective('delete', 'performance')
admin_role.permissions << Permission.find_by_action_and_objective('manage', 'group')

user_role = Role.find_or_create_by_name_and_stage_type "User", "Space"
user_role.permissions << Permission.find_by_action_and_objective('read',   nil)
user_role.permissions << Permission.find_by_action_and_objective('create', 'content')
user_role.permissions << Permission.find_by_action_and_objective('read',   'content')
user_role.permissions << Permission.find_by_action_and_objective('update', 'attachment')
user_role.permissions << Permission.find_by_action_and_objective('create', 'performance')
user_role.permissions << Permission.find_by_action_and_objective('read',   'performance')

invited_role = Role.find_or_create_by_name_and_stage_type "Invited", "Space"
invited_role.permissions << Permission.find_by_action_and_objective('read', nil)
invited_role.permissions << Permission.find_by_action_and_objective('read', 'content')
invited_role.permissions << Permission.find_by_action_and_objective('read', 'performance')

puts "* Create the default BigBlueButton server"
puts "  name: #{config["bbb_server_name"]}"
puts "  url: #{config["bbb_server_url"]}"
puts "  salt: #{config["bbb_server_salt"]}"
puts "  version: #{config["bbb_server_version"]}"
bbb_server = BigbluebuttonServer.create :name => config["bbb_server_name"],
                                        :url => config["bbb_server_url"],
                                        :salt => config["bbb_server_salt"],
                                        :version => config["bbb_server_version"]

puts "* Create the administrator account"
puts "  login: #{config["admin_login"]}"
puts "  email: #{config["admin_email"]}"
puts "  password: #{config["admin_password"]}"
puts "  fullname: #{config["admin_fullname"]}"
u = User.create :login => config["admin_login"],
                :email => config["admin_email"],
                :password => config["admin_password"],
                :password_confirmation => config["admin_password"],
                :_full_name => config["admin_fullname"]
u.update_attribute(:superuser,true)
u.activate
u.profile!.update_attribute(:full_name, config["admin_fullname"])
