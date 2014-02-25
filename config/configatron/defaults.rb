# Put all your default configatron settings here.

# Example:
#   configatron.emails.welcome.subject = 'Welcome!'
#   configatron.emails.sales_reciept.subject = 'Thanks for your order'
#
#   configatron.file.storage = :s3

# Make sure the config file exists and load it
CONFIG_FILE = File.join(::Rails.root, "config", "setup_conf.yml")
unless File.exists? CONFIG_FILE
  puts
  puts "ERROR"
  puts "The configuration file does not exist!"
  puts "Path: #{CONFIG_FILE}"
  puts
  exit
end

# Load the configuration file into configatron
full_config = YAML.load_file(CONFIG_FILE)
config = full_config["default"]
config_env = full_config[Rails.env]
config.merge!(config_env) unless config_env.nil?
configatron.configure_from_hash(config)

# List of locales available in the application.
# We can't use `I18n.available_locales` because it returns all locales available including the
# ones included by gems, so if a gem has any locale the application doesn't, it would show up.
configatron.i18n.default_locales = [:en, :"pt-br"]

# Whether or not the event module was loaded.
# Use to know whether things like routes, helpers, and abilities from the module should be
# loaded.
configatron.modules.events.loaded = false
