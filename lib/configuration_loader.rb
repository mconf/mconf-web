require 'configatron'

class ConfigurationLoader

  def self.load(file, env='development')
    full_config = YAML.load_file(file)
    config = full_config["default"]
    config_env = full_config[env]
    config.merge!(config_env) unless config_env.nil?

    configatron.configure_from_hash(config)
  end

end
