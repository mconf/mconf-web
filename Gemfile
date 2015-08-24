source 'https://rubygems.org'

gem 'rack', '~> 1.5.4'
gem 'rails', '~> 4.1.11'
gem 'sass-rails', '~> 4.0.4'
gem 'coffee-rails', '~> 4.0.0'
gem 'uglifier', '>= 1.0.3'
gem 'jquery-rails', '~> 3.1.3'
gem 'yui-compressor'
gem 'compass-rails', '~> 2.0'
gem 'handlebars_assets'
gem 'select2-rails'

# TODO: remove when compass-rails is updated to support animations
# This compass is here so we can have css3/animation
gem 'compass', '~> 0.13.alpha'

gem 'mysql2', '~> 0.3.0'
gem 'rake'
gem 'therubyracer', :require => 'v8'
gem 'haml'
gem 'will_paginate'
gem 'chronic'
gem 'rails_autolink', '~> 1.1.0'
gem 'simple_form', '~> 3.1.0'
gem 'acts_as_tree', '~> 2.0.0'
gem 'friendly_id'
gem 'i18n-js', :git => "https://github.com/fnando/i18n-js.git"
gem 'rabl'
gem 'yajl-ruby' # json parser for rabl
gem 'valid_email', '~> 0.0.10'#, :git => 'https://github.com/Fire-Dragon-DoL/valid_email.git'
gem 'public_activity', '~> 1.4.1'

# For queues
gem 'resque', :require => 'resque/server'
gem 'resque-scheduler', :require => 'resque/scheduler/server'
gem 'resque_mailer'

# Authentication and authorization
gem 'devise', '~> 3.5.1'
gem 'devise-encryptable' # TODO: only while we have old station users
gem 'cancancan', '~> 1.9'
gem 'devise-async'
gem 'net-ldap'

# BigBlueButton integration
gem 'bigbluebutton-api-ruby', :git => 'https://github.com/mconf/bigbluebutton-api-ruby.git', :branch => 'master'
gem 'bigbluebutton_rails', :git => 'https://github.com/mconf/bigbluebutton_rails.git', :branch => 'master'

# Used on Profile to generate a vcard
gem 'vpim', :git => 'https://github.com/sam-github/vpim.git'

# for logos + attachments
gem 'carrierwave', '~> 0.10.0'
gem 'rmagick'
gem 'mini_magick'

# global configurations
# TODO: update to the stable version when out
gem 'configatron', '~> 2.13.0'

# for bootstrap
gem 'less-rails'
gem 'twitter-bootstrap-rails', '~> 2.2.8'
# datetime picker for bootstrap
gem 'bootstrap3-datetimepicker-rails', '~> 3.1.3'

# moment.js for dates
gem 'momentjs-rails', '>= 2.8.1'

gem 'sprockets', '~> 2.12.3'

# font-awesome (recommended to be here, not in the assets group)
gem 'font-awesome-rails', '~> 4.1.0.0'

# to format emails
gem 'premailer-rails'
gem 'nokogiri'

# event module
gem 'mweb_events', :git => 'https://github.com/mconf/mweb_events.git', :branch => 'master'

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

#
# TODO: Gems to review if we can remove/update
#
gem 'httparty'
gem 'rubyzip', '>= 1.0.0' # will load new rubyzip version
gem 'zip-zip' # will load compatibility for old rubyzip API.
gem 'prism'

gem 'fineuploader-rails', '~> 3.3'

gem 'resque-lock-timeout'

group :development do
  gem 'translate-rails3', :require => 'translate', :git => 'https://github.com/mconf/translate.git'
  gem 'rails-footnotes'
  gem 'quiet_assets'
  gem 'brakeman', :require => false
  gem 'librarian-chef'
  gem 'mailcatcher'

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
  gem 'shoulda-matchers', '~> 2.6.1', :require => false
  gem 'shoulda-kept-assign-to'
  gem 'htmlentities', '~> 4.3.3'
  gem 'turn', '0.8.2', :require => false # TODO: why 0.8.2?
  gem 'simplecov', :require => false
  gem 'fooldap'
  gem 'spring'
  gem 'zonebie'
end

group :test do
  gem 'resque_spec'
  gem 'database_cleaner'
end
