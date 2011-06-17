# Make sure the config file exists and load it
CONFIG_FILE = File.join(::Rails.root, "config", "setup_conf.yml")
unless File.exists? CONFIG_FILE
  puts
  puts "ERROR"
  puts "The configuration file does not exists!"
  puts "Path: #{CONFIG_FILE}"
  puts
  puts "Did you run \"rake setup:basic\"? Run it and then edit the file generated."
  puts
  exit
end

ConfigurationLoader.load(CONFIG_FILE, Rails.env)
#full_config = YAML.load_file(CONFIG_FILE)
#config = full_config["default"]
#env = full_config[Rails.env]
#config.merge!(env) unless env.nil?
#configatron.configure_from_hash(config)


