# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.2.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
require File.join(File.dirname(__FILE__), '../vendor/plugins/engines/boot')

Rails::Initializer.run do |config|
  # Allowed html tags for sanitize  
  
  config.action_view.sanitized_allowed_tags = 'table', 'tr', 'td', 'embed'

  
  # Settings in config/environments/* take precedence over those specified here
  
  config.action_controller.session = { :secret => " secret phrase of at least 30 characters" }
   
  
  # Skip frameworks you're not going to use (only works if using vendor/rails)
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  # Only load the plugins named here, by default all plugins in vendor/plugins are loaded
  config.plugins = %W( ultrasphinx simple_captcha all )

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  config.active_record.observers = :user_observer, :invitation_observer

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc

  # Add new inflection rules using the following format
  # (all these examples are active by default):
  # Inflector.inflections do |inflect|
  #   inflect.plural /^(ox)$/i, '\1en'
  #   inflect.singular /^(ox)en/i, '\1'
  #   inflect.irregular 'person', 'people'
  #   inflect.uncountable %w( fish sheep )
  # end

  # See Rails::Configuration for more options
  config.gem "rspec-rails",          :lib => false 
                                    
  
  
end

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register "application/x-mobile", :mobile

# Include your application configuration below
ActionMailer::Base.raise_delivery_errors = true
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
  :address => "jungla.dit.upm.es",
  :port => 25,
  :domain => "dit.upm.es",
  
 
  }
  ActionMailer::Base.perform_deliveries = true
  ActionMailer::Base.default_charset = "utf-8"  
  
