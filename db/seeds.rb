# This file should contain all the record creation needed to seed the
# database with its default values. The data can then be loaded with
# the rake db:seed (or created alongside the db with db:setup).

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
puts "  smtp_login: #{config["site_smtp_login"]}"
puts "  smtp_password: #{config["site_smtp_password"].gsub(/./, "*") unless config["site_smtp_password"].blank?}"
puts "  smtp configurations defaults to Gmail"
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
params = { :name => config["site_name"],
           :description => config["site_description"],
           :smtp_login => config["site_smtp_login"],
           :smtp_sender => config["site_smtp_login"],
           :smtp_password => config["site_smtp_password"],
           :smtp_auto_tls => true,
           :smtp_server => "smtp.gmail.com",
           :smtp_port => 587,
           :smtp_use_tls => true,
           :smtp_domain => "gmail.com",
           :smtp_auth_type => :plain,
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
         }
if Site.count > 0
  Site.current.update_attributes params
else
  Site.create! params
end

puts "* Create Roles"
Role.create! :name => 'User', :stage_type => 'Space'
Role.create! :name => 'Admin', :stage_type => 'Space'
Role.create! :name => 'Participant', :stage_type => 'Event'
Role.create! :name => 'Organizer', :stage_type => 'Event'

puts "* Create the default BigBlueButton server"
puts "  name: #{config["bbb_server_name"]}"
puts "  url: #{config["bbb_server_url"]}"
puts "  salt: #{config["bbb_server_salt"]}"
puts "  version: #{config["bbb_server_version"]}"
BigbluebuttonServer.create! :name => config["bbb_server_name"],
                            :url => config["bbb_server_url"],
                            :salt => config["bbb_server_salt"],
                            :version => config["bbb_server_version"]

puts "* Create the administrator account"
puts "  username: #{config["admin_username"]}"
puts "  email: #{config["admin_email"]}"
puts "  password: #{config["admin_password"]}"
puts "  fullname: #{config["admin_fullname"]}"
u = User.new :username => config["admin_username"],
             :email => config["admin_email"],
             :password => config["admin_password"],
             :password_confirmation => config["admin_password"],
             :_full_name => config["admin_username"],
             :created_at => DateTime.now,
             :superuser => true
u.skip_confirmation!
unless u.save(:validation => false)
  puts "ERROR!"
  puts u.errors.inspect
end
u.profile!.update_attribute(:full_name, config["admin_fullname"])
