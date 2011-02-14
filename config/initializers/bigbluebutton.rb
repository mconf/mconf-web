require 'bigbluebutton-api'

BBB_CONFIG = YAML.load_file(File.join(Rails.root, "config", "bigbluebutton_conf.yml"))[RAILS_ENV]
BBB_API = BigBlueButton::BigBlueButtonApi.new(BBB_CONFIG["server"], BBB_CONFIG["salt"], BBB_CONFIG["version"], RAILS_ENV != :production)
