# coding: utf-8
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

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
    config.autoload_paths += %W(#{config.root}/lib/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]
    # config.plugins = [ :simple_captcha, :slug_fu, :all ]
    config.plugins = [:all]

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = 'Madrid'

    # Need to set it directly on I18n because we have other gems that require I18n and might
    # be setting this first.
    # A tip from http://stackoverflow.com/questions/20361428/rails-i18n-validation-deprecation-warning
    I18n.config.enforce_available_locales = true

    # The translations are stored in config/locales/**/*.yml, in separate files for base strings,
    # gem strings and application strings (mconf.yml). The application strings should always be
    # loaded after all the others, so that it can override strings.
    config.i18n.load_path +=
      Dir[Rails.root.join('config', 'locales', '**', '_*.yml').to_s] +
      Dir[Rails.root.join('config', 'locales', '**', 'mconf.yml').to_s]
    config.i18n.fallbacks = true
    config.i18n.enforce_available_locales = true
    config.i18n.available_locales = [:bg, :de, :en, :"es-419", :"pt-br", :ru]
    config.available_locales_countries = [:bg, :de, :en, :es, :pt, :ru] # for the countries gem
    config.i18n.default_locale = :en

    config.generators do |g|
      g.fixture_replacement :factory_girl
    end

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, :password_confirmation]

    # Load files inside the lib folder. Not the best approach, see http://www.strictlyuntyped.com/2008/06/rails-where-to-put-other-files.html
    config.autoload_paths += %W( #{ Rails.root }/lib )

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # all view helpers loaded for all views
    config.action_controller.include_all_helpers = true

    # add the views for the mailers in the path
    config.paths['app/views'].unshift("#{Rails.root}/app/mailers/views")

    config.exceptions_app = self.routes

    config.locale_names =
      {
        bg: "Български",
        de: "Deutsch",
        en: "English",
        "es-419": "Español",
        "pt-br": "Português",
        ru: "Pусский"
      }

    # Set to true so all users are created with permission to record
    config.can_record_default = ENV['MCONF_CAN_RECORD_DEFAULT'] == 'true'

    # Scope for all URLs related to conferences
    # and for the short URLs used to join a conference
    config.conf_scope       = ENV['MCONF_CONFERENCE_SCOPE'] || 'conference'
    config.conf_scope_rooms = ENV['MCONF_CONFERENCE_SCOPE_ROOMS'] || 'conference'

    # Redis configurations. Defaults to a localhost instance.
    config.redis_host      = ENV['MCONF_REDIS_HOST'] || 'localhost'
    config.redis_port      = ENV['MCONF_REDIS_PORT'] || 6379
    config.redis_db        = ENV['MCONF_REDIS_DB'] || 0
    config.redis_password  = ENV['MCONF_REDIS_PASSWORD'] || nil

    # Email tracking
    config.email_track_opened  = ENV['MCONF_EMAIL_TRACK_OPENED'] == 'true'
    config.email_track_clicked = ENV['MCONF_EMAIL_TRACK_CLICKED'] == 'true'

    # To set the URL of an external frontpage
    # If empty (default), will use the standard frontpage
    config.external_frontpage = ENV['MCONF_EXTERNAL_FRONTPAGE']

    # Themes: set to the theme name if using any!
    config.theme = ENV['MCONF_THEME']

    # Social login API Keys
    config.omniauth_google_key       = ENV['MCONF_OMNIAUTH_GOOGLE_KEY'] || nil
    config.omniauth_facebook_key     = ENV['MCONF_OMNIAUTH_FACEBOOK_KEY'] || nil
    config.omniauth_google_secret    = ENV['MCONF_OMNIAUTH_GOOGLE_SECRET'] || nil
    config.omniauth_facebook_secret  = ENV['MCONF_OMNIAUTH_FACEBOOK_SECRET'] || nil

    # Set permissions to record when users join conferences instead of when meetings are created.
    # Set if to false to use the old model based on the `record` flag on the `create` API call.
    config.per_user_record_permissions = ENV['MCONF_PER_USER_RECORD_PERMISSIONS'] == 'true'

    # Authenticate playback URLs for recordings
    config.playback_url_authentication = ENV['MCONF_PLAYBACK_URL_AUTH'] == 'true'
    # Show the playback in an iframe. If false, redirects the user to the playback page.
    config.playback_iframe = ENV['MCONF_PLAYBACK_IFRAME'] == 'true'

    # Themes: configure assets paths here!
    # config.assets.paths << Rails.root.join("app", "assets", "themes", "my-theme", "stylesheets")
    # config.assets.paths << Rails.root.join("app", "assets", "themes", "my-theme", "images")
  end
end
