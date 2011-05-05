require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

# Specifies gem version of Rails to use when vendor/rails is not present
# RAILS_GEM_VERSION = '3.0.3' unless defined? RAILS_GEM_VERSION

module Vcc
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]
    # config.plugins = [ :ultrasphinx, :simple_captcha, :permalink_fu, :all ]
    config.plugins = [ :simple_captcha, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer
    config.active_record.observers = :user_observer, :admission_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = 'Madrid'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # TODO test if it really falls back to en
    config.i18n.fallbacks = true
    config.i18n.default_locale = :en

    config.generators do |g|
      g.fixture_replacement :factory_girl
      #g.template_engine :haml
    end

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)
    # Allowed html tags for sanitize
    # TODO rails 3: sanitized_allowed
    #config.action_view.sanitized_allowed_tags = 'table', 'tr', 'td', 'embed', 'u'
    #config.action_view.sanitized_allowed_attributes = 'id', 'class', 'style', 'allowfullscreen', 'wmode'

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Load files inside the lib folder. Not the best approach, see http://www.strictlyuntyped.com/2008/06/rails-where-to-put-other-files.html
    config.autoload_paths += %W( #{ Rails.root }/lib )
  end
end
