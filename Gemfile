source 'https://rubygems.org'

gem 'rails', '~> 4.1.4'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', '~> 4.0.3'
  gem 'coffee-rails', '~> 4.0.0'
  gem 'uglifier', '>= 1.0.3'
  gem 'jquery-rails', '~> 3.1.1'
  gem 'yui-compressor'
  gem 'compass-rails', '~> 1.0'
  gem 'handlebars_assets'

  # TODO: remove when compass-rails is updated
  # This compass is here so we can have css3/animation
  gem 'compass', '~> 0.13.alpha'
  gem 'select2-rails'
end

gem 'mysql2', '~> 0.3.0'
gem 'rake'
gem 'therubyracer', :require => 'v8'
gem 'haml'
gem 'will_paginate'
gem 'chronic'
gem 'rails_autolink', '~> 1.1.0'
gem 'whenever', :require => false
gem 'garb'
gem 'simple_form', '~> 3.0.0'
gem 'acts_as_tree', '~> 2.0.0'
gem 'friendly_id'
gem 'i18n-js', :git => "git://github.com/fnando/i18n-js.git", :branch => 'rewrite'
gem 'rabl'
gem 'yajl-ruby' # json parser for rabl
gem 'valid_email', :git => 'https://github.com/Fire-Dragon-DoL/valid_email.git'
gem 'public_activity', '~> 1.4.1'

# For queues
gem 'resque', :require => 'resque/server'
gem 'resque-scheduler', :require => 'resque/scheduler/server'
gem 'resque_mailer'

# Authentication and authorization
gem 'devise', '~> 3.2.4'
gem 'devise-encryptable' # TODO: only while we have old station users
gem 'cancancan', '~> 1.9'
gem 'devise-async'
gem 'net-ldap'

# BigBlueButton integration
gem 'bigbluebutton-api-ruby', :git => 'git://github.com/mconf/bigbluebutton-api-ruby.git', :branch => 'master'
gem 'bigbluebutton_rails', :git => 'git://github.com/mconf/bigbluebutton_rails.git', :branch => 'master'
# The gems below are for bigbluebutton_rails
gem 'browser'

# Used on Profile to generate a vcard
gem 'vpim' # TODO: very old, last update on 2009

# for logos + attachments
gem 'carrierwave', '~> 0.10.0'
gem 'rmagick'

# global configurations
# TODO: update to the stable version when out
gem 'configatron', '~> 2.13.0'

# for bootstrap
gem 'less-rails'
gem 'twitter-bootstrap-rails', '~> 2.2.8'
# datetime picker for bootstrap
gem 'bootstrap-datetimepicker-rails'

# moment.js for dates
gem 'momentjs-rails'

# font-awesome (recommended to be here, not in the assets group)
gem 'font-awesome-rails', '~> 4.1.0.0'

# to format emails
gem 'premailer-rails'
gem 'nokogiri'

# event module
gem 'mweb_events', :git => 'git@github.com:mconf/mweb_events.git', :branch => 'master'

# send emails in case of exceptions in production
gem 'exception_notification', '~> 4.0.0'

# generate .ics
gem 'icalendar'

#
# TODO: Gems to review if we can remove/update
#
gem 'simple_captcha2', require: 'simple_captcha'
# gem 'galetahub-simple_captcha', :require => 'simple_captcha'
gem 'httparty'
gem 'rubyzip' # TODO: see rubyzip2
gem 'prism'

gem 'fineuploader-rails', '~> 3.3'

group :development do
  gem 'translate-rails3', :require => 'translate', :git => 'git://github.com/mconf/translate.git'
  gem 'rails-footnotes'

  # to show better error pages, with more information
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'webrick', '~> 1.3.1'
  gem 'quiet_assets'
end

group :development, :test do
  gem 'rspec-rails', '~> 2.99.0'
  gem 'rspec-mocks'
  gem 'populator'
  # Until timezone bug is fixed
  gem 'forgery', :git => 'https://github.com/sevenwire/forgery.git'
  gem 'factory_girl_rails'
  gem 'sqlite3'
  gem 'webrat'
  gem 'capybara'
  gem 'launchy'
  gem 'shoulda-matchers', '~> 2.6.1', :require => false
  gem 'shoulda-kept-assign-to'
  gem 'htmlentities'
  gem 'turn', '0.8.2', :require => false # TODO: why 0.8.2?
  gem 'simplecov', :require => false
end

group :test do
  gem 'resque_spec'
end

# rails 3 compatibility
gem 'rails-observers'
