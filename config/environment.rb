# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.4' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Allowed html tags for sanitize  
  config.action_view.sanitized_allowed_tags = 'table', 'tr', 'td', 'embed', 'u'
  config.action_view.sanitized_allowed_attributes = 'id', 'class', 'style', 'allowfullscreen', 'wmode'

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"
  config.gem "rspec-rails", :lib => false 

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  config.plugins = [ :ultrasphinx, :simple_captcha, :permalink_fu, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  config.active_record.observers = :user_observer, :admission_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'Madrid'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
 
end

  # smtp_settings - Allows detailed configuration for :smtp delivery method:
  #  :address - Allows you to use a remote mail server. Just change it from its default "localhost" setting.
  #  :port - On the off chance that your mail server doesn‘t run on port 25, you can change it.
  #  :domain - If you need to specify a HELO domain, you can do it here.
  #  :user_name - If your mail server requires authentication, set the username in this setting.
  #  :password - If your mail server requires authentication, set the password in this setting.
  #  :authentication - If your mail server requires authentication, you need to specify the authentication type here. This is a symbol and one of :plain, :login, :cram_md5.
  #  :enable_starttls_auto - When set to true, detects if STARTTLS is enabled in your SMTP server and starts to use it. It works only on Ruby >= 1.8.7 and Ruby >= 1.9. Default is true.
  ActionMailer::Base.raise_delivery_errors = true
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.perform_deliveries = true
  ActionMailer::Base.default_charset = "utf-8"
  ActionMailer::Base.smtp_settings = {
    :address => "jungla.dit.upm.es",
    :port => 25,
    :domain => "dit.upm.es"
  }
