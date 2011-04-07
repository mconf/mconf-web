require 'bigbluebutton-api'

#BBB_CONFIG = YAML.load_file(File.join(Rails.root, "config", "bigbluebutton_conf.yml"))[RAILS_ENV]
#BBB_API = BigBlueButton::BigBlueButtonApi.new(BBB_CONFIG["server"], BBB_CONFIG["salt"], BBB_CONFIG["version"], RAILS_ENV != :production)
if defined?(BigbluebuttonServer)
  server = BigbluebuttonServer.first
  BBB_API = BigBlueButton::BigBlueButtonApi.new(server.url, server.salt, server.version, RAILS_ENV != :production)
end
