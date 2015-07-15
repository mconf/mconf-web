# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

Mconf::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false
  # Set to false to test the production env locally using rails s -e production
  # config.serve_static_assets = true

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Compress css files with yui
  config.assets.css_compressor = :yui

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to Rails.root.join("public/assets")
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # Every js or css in the root directory is compiled, except the ones started by "_"
  config.assets.precompile +=
    Dir.glob("#{Rails.root}/app/assets/{stylesheets,javascripts}/[^_]*.{css,scss,js,coffee}").map{ |f| File.basename(f).gsub(/\.(scss|coffee)/, '') }
  # Add all images from vendored assets. Just images, css and js files are required by our css and js
  # files, do they do not need their own route.
  config.assets.precompile +=
    Dir.glob("#{Rails.root}/vendor/assets/**/*.{png,jpg,gif}")

  # Disable delivery errors, bad email addresses will be ignored
  # TODO: review
  config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  config.eager_load = true

  # Configs for lograge
  config.lograge.enabled = true
  config.lograge.custom_options = lambda do |event|
    params = event.payload[:params].reject do |k|
      ['controller', 'action'].include? k
    end
    hash = {
      time: event.time,
      current_user: event.payload[:current_user]
    }
    hash.merge!({ params: params }) unless params.blank?
    hash.merge!({ session: event.payload[:session] }) unless event.payload[:session].nil?
    hash
  end
  config.lograge.keep_original_rails_log = true
  config.lograge.logger = ActiveSupport::Logger.new "#{Rails.root}/log/lograge_#{Rails.env}.log"
  config.lograge.formatter = Lograge::Formatters::Logstash.new
end
