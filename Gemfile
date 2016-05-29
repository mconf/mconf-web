source 'https://rubygems.org'

gem 'rack', '~> 1.5.4'
gem 'rails', '~> 4.1.14.2'
gem 'sass-rails', '~> 4.0.4'
gem 'coffee-rails', '~> 4.0.0'
gem 'uglifier', '>= 1.0.3'
gem 'jquery-rails', '~> 3.1.3'
gem 'yui-compressor'
gem 'compass-rails', '~> 2.0'
gem 'handlebars_assets'
gem 'select2-rails'

# To use sql UNION with activerecord
gem 'active_record_union', '~> 1.1.0'

# To DRY controllers
gem 'inherited_resources', '~> 1.6.0'

# TODO: remove when compass-rails is updated to support animations
# This compass is here so we can have css3/animation
gem 'compass', '~> 0.12'

gem 'mysql2', '~> 0.3.0'
gem 'rake', '~> 10.5.0'
gem 'therubyracer', :require => 'v8'
gem 'haml'
gem 'will_paginate'
gem 'chronic'
gem 'rails_autolink', '~> 1.1.0'
gem 'simple_form', '~> 3.1.0'
gem 'acts_as_tree', '~> 2.0.0'
gem 'friendly_id', '~> 5.0.4'
gem 'i18n-js', '~> 3.0.0.rc12'
gem 'rabl'
gem 'yajl-ruby' # json parser for rabl
gem 'valid_email', '~> 0.0.10'#, :git => 'https://github.com/Fire-Dragon-DoL/valid_email.git'
gem 'public_activity', '~> 1.4.1'

# For queues
gem 'resque', '~> 1.25.2', :require => 'resque/server'
gem 'resque-scheduler', :require => 'resque/scheduler/server'
gem 'resque_mailer'
gem 'resque-lock-timeout'

# Authentication and authorization
gem 'bcrypt', '~> 3.1.5'
gem 'devise', '~> 3.5.4'
gem 'devise-encryptable' # TODO: #1271 only while we have old station users
gem 'cancancan', '~> 1.9'
gem 'devise-async'
gem 'net-ldap'

# BigBlueButton integration
gem 'bigbluebutton-api-ruby', :git => 'https://github.com/mconf/bigbluebutton-api-ruby.git', :branch => 'master'
gem 'bigbluebutton_rails', :git => 'https://github.com/mconf/bigbluebutton_rails.git', :branch => 'master'

# Used on Profile to generate a vcard
gem 'vpim', '~> 13.11.11'

# for logos + attachments
gem 'carrierwave', '~> 0.10.0'
gem 'rmagick', '~> 2.13.2'
gem 'mini_magick', '~> 3.8.1'

# global configurations
gem 'configatron', '~> 2.13.0'

# for bootstrap
gem 'bootstrap-sass', '~> 3.3'
gem 'autoprefixer-rails'
# datetime picker for bootstrap
gem 'bootstrap3-datetimepicker-rails', '~> 3.1.3'

# moment.js for dates
gem 'momentjs-rails', '>= 2.8.1'

gem 'sprockets', '~> 2.12.4'

# font-awesome (recommended to be here, not in the assets group)
gem 'font-awesome-rails', '~> 4.1'

# to format emails
gem 'premailer-rails'
gem 'nokogiri'

# send emails in case of exceptions in production
gem 'exception_notification', '~> 4.0.0'

# generate .ics
gem 'icalendar'

# More precise distance_of_time_in_words and time_ago_in_words
gem 'dotiw'

# Sanity check on database
gem 'active_sanity'

# Turn rails logs into json
gem "lograge"
gem "logstash-event"

# Uploads
gem 'fineuploader-rails', git: 'https://github.com/mconf/fineuploader-rails.git'
gem 'filesize'

#
# TODO: Gems to review if we can remove/update
#
gem 'httparty'
gem 'rubyzip', '>= 1.0.0' # will load new rubyzip version
gem 'zip-zip' # will load compatibility for old rubyzip API.
gem 'prism'

group :development do
  gem 'translate-rails3', :require => 'translate', :git => 'https://github.com/mconf/translate.git'
  gem 'rails-footnotes'
  gem 'quiet_assets'
  gem 'brakeman', :require => false
  gem 'librarian-chef'
  gem 'mailcatcher'
  gem 'xray-rails'

  # to show better error pages, with more information
  gem 'better_errors'
  gem 'binding_of_caller'
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
  gem "capybara-webkit"
  gem 'launchy'
  gem 'shoulda-matchers', '~> 3.0'
  gem 'shoulda-kept-assign-to'
  gem 'htmlentities', '~> 4.3.3'
  gem 'turn', '0.8.2', :require => false # TODO: why 0.8.2?
  gem 'simplecov', :require => false
  gem 'fooldap'
  gem 'spring'
  gem 'zonebie'
  gem 'timecop'
end

group :test do
  gem 'resque_spec'
  gem 'database_cleaner'
  gem 'webmock', require: false
  gem 'codeclimate-test-reporter', group: :test, require: nil
end

# Events module
gem 'geocoder'
gem 'redcarpet'
gem 'epic-editor-rails'
gem 'leaflet-rails'
