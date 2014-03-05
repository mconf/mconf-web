source 'http://rubygems.org'

gem 'rails', '3.2.11'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', '~> 3.2.0'
  gem 'coffee-rails', '~> 3.2.0'
  gem 'uglifier', '>= 1.0.3'
  gem 'yui-compressor'
  gem 'compass-rails', '~> 1.0'
  gem 'handlebars_assets'

  # TODO: remove when compass-rails is updated
  # This compass is here so we can have css3/animation
  gem 'compass', '~> 0.13.alpha'
  gem 'select2-rails'
end

gem 'gon', '3.0.5'
gem 'mysql2', '~> 0.3.0'
gem 'rake'
gem 'jquery-rails'
gem 'therubyracer', :require => 'v8'
gem 'haml'
gem 'will_paginate'
gem 'chronic'
gem 'yaml_db'
gem 'delayed_job', '~> 3.0.0'
gem 'delayed_job_active_record'
gem 'daemons' # for delayed_job
gem 'rails_autolink'
gem 'whenever', :require => false
gem 'garb'
gem 'simple_form', '~> 2.1.0'
gem 'acts_as_tree', :git => 'https://github.com/parasew/acts_as_tree.git'
gem 'friendly_id'
gem 'i18n-js', :git => "git://github.com/fnando/i18n-js.git", :branch => 'rewrite'
gem 'rabl'
gem 'yajl-ruby' # json parser for rabl
gem 'valid_email', :git => 'https://github.com/Fire-Dragon-DoL/valid_email.git'
gem 'public_activity'

# Authentication and authorization
gem 'devise'
gem 'devise-encryptable' # TODO: only while we have old station users
gem 'cancan', '~> 1.6.0'
gem 'station', :git => 'git://github.com/mconf/station.git', :branch => 'mweb-v2'
gem 'net-ldap'

# BigBlueButton integration
gem 'bigbluebutton-api-ruby', :git => 'git://github.com/mconf/bigbluebutton-api-ruby.git', :branch => 'master'
gem 'bigbluebutton_rails', :git => 'git://github.com/mconf/bigbluebutton_rails.git', :branch => 'branch-v1.4.0'
gem 'strong_parameters' # for bigbluebutton_rails
gem 'resque' # for bigbluebutton_rails

# Used on Profile to generate a vcard
gem 'vpim' # TODO: very old, last update on 2009

# for logos
gem 'carrierwave'
gem 'rmagick'

# global configurations
# TODO: update to the stable version when out
gem 'configatron', '~> 2.13.0'

# for bootstrap
gem 'less-rails'
gem 'twitter-bootstrap-rails'
# datetime picker for bootstrap
gem 'bootstrap-datetimepicker-rails'

# moment.js for dates
gem 'momentjs-rails'

# font-awesome (recommended to be here, not in the assets group)
gem 'font-awesome-rails'

# to format emails
gem 'premailer-rails'
gem 'nokogiri'

# send emails in case of exceptions in production
gem 'exception_notification'

# generate .ics
gem 'icalendar'

#
# TODO: Gems to review if we can remove/update
#
gem 'galetahub-simple_captcha', :require => 'simple_captcha'
gem 'attachment_fu', :git => 'git://github.com/mconf/attachment_fu.git'
gem 'hpricot'
gem 'feed-normalizer'
gem 'httparty'
gem 'ci_reporter'
gem 'rubyzip' # TODO: see rubyzip2
gem 'dynamic_form'
gem 'prism'
# not the official repo, but has fixes for rails 3
gem 'table_helper', :git => 'git://github.com/eeng/table_helper.git'

group :development do
  gem 'translate-rails3', :require => 'translate', :git => 'git://github.com/mconf/translate.git'
  gem 'spork-rails'
  gem 'rails-footnotes'
end

group :development, :test do
  gem 'rspec-rails', '~> 2.14'
  gem 'populator'
  gem 'ffaker'
  gem 'forgery'
  gem 'factory_girl_rails'
  gem 'sqlite3'
  gem 'webrat'
  gem 'shoulda-matchers'
  gem 'htmlentities'
  gem 'turn', '0.8.2', :require => false # TODO: why 0.8.2?
  gem 'simplecov'
end
