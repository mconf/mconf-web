require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Mconf
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
    config.active_record.observers = :user_observer, :admission_observer, :bigbluebutton_rooms_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = 'Madrid'

    # The translations are stored in config/locales/**/*.yml, in separate files for base strings,
    # gem strings and application strings (mconf.yml). The application strings should always be
    # loaded after all the others, so that it can override strings.
    config.i18n.load_path +=
      Dir[Rails.root.join('config', 'locales', '**', '_*.yml').to_s] +
      Dir[Rails.root.join('config', 'locales', '**', 'mconf.yml').to_s]
    config.i18n.fallbacks = true
    config.i18n.default_locale = :en

    config.generators do |g|
      g.fixture_replacement :factory_girl
    end

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Load files inside the lib folder. Not the best approach, see http://www.strictlyuntyped.com/2008/06/rails-where-to-put-other-files.html
    config.autoload_paths += %W( #{ Rails.root }/lib )

    # Enable the asset pipeline
    config.assets.enabled = true

    config.assets.precompile << /(^[^_]|\/[^_])[^\/]*/

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'
  end
end
