# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.1.1' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
require File.join(File.dirname(__FILE__), '../vendor/plugins/engines/boot')


Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here
  
  config.action_controller.session = { :secret => " secret phrase of at least 30 characters" }
   
  
  # Skip frameworks you're not going to use (only works if using vendor/rails)
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  # Only load the plugins named here, by default all plugins in vendor/plugins are loaded
  # config.plugins = %W( exception_notification ssl_requirement )

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
  config.gem "mislav-will_paginate", :lib => 'will_paginate',
                                     :version => '>= 2.3.2',
                                     :source => 'http://gems.github.com/'
end
include CMS
include Globalize
Locale.set_base_language 'en-US'
LOCALES = {'en' => 'en-US',
           'es' => 'es-ES',
           'fr' => 'fr-FR'}.freeze
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
  
  ENV['ISABEL_DIR'] = "/usr/local/isabel/"
  ENV['ISABEL_USER_DIR'] = ENV['HOME'] + "/.isabel"
  ENV['ISABEL_SESSIONS_DIR'] = ENV['ISABEL_USER_DIR']+"/sessions/4.11"
  ENV['ISABEL_CONFIG_DIR'] = ENV['ISABEL_USER_DIR']+"/config"
  ENV['ISABEL_PROFILES_DIR'] = ENV['ISABEL_CONFIG_DIR'] +"/profiles/4.11"

  #First of all we check if IsabelGuard is executing with the command fp (equivalent to ps -ef)
  fp_isabelGuard = "fp IsabelGuard"
  fp_IO = IO.popen(fp_isabelGuard)
  output = fp_IO.readlines
  #Only launch IsabelGuard if it is not launched already
  if output.length <= 1     #the first line is not a command is the titles
      isabelguard_libs = " /usr/local/isabel/libexec/isabel_tunnel.jar:/usr/local/isabel/extras/libexec/xmlrpc/commons-logging-1.1.jar:" + 
          "/usr/local/isabel/extras/libexec/xmlrpc/ws-commons-util-1.0.2.jar:/usr/local/isabel/extras/libexec/xmlrpc/xmlrpc-common-3.1.jar:" + 
          "/usr/local/isabel/extras/libexec/xmlrpc/servlet-api.jar:/usr/local/isabel/extras/libexec/xmlrpc/xmlrpc-client-3.1.jar:" +
          "/usr/local/isabel/extras/libexec/xmlrpc/xmlrpc-server-3.1.jar:" + RAILS_ROOT + "/lib/mysql-connector-java-5.1.5-bin.jar:" +
          "/usr/local/isabel/libexec/isabel_xlimservices.jar:/usr/local/isabel/libexec/xedl.jar:" + 
          "/usr/local/isabel/libexec/isabel_xlim.jar:/usr/local/isabel/lib/images/xlim/:"+
          "/usr/local/isabel/libexec/isabel_lib.jar -Dprior.config.file=/usr/local/isabel/lib/xlimconfig/priorxedl.cfg"+
          " -Disabel.dir=/usr/local/isabel/ -Disabel.profiles.dir=/home/ebarra/.isabel/config/profiles/4.11" +
          " -Disabel.sessions.dir=/home/ebarra/.isabel/sessions/4.11 -Disabel.user.dir=/home/ebarra/.isabel" + 
          " -Disabel.config.dir=/home/ebarra/.isabel/config "
      command_isabelguard = "java -cp " + isabelguard_libs + " services/isabel/services/isabelGuard/IsabelGuard > " + ENV['ISABEL_USER_DIR'] + 
                            "/logs/isabelGuard.log 2>&1 &"
      object_IO = IO.popen(command_isabelguard)
   end
