source 'http://rubygems.org'

gem 'rails', '~> 3.1.0'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.1.5'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier', '>= 1.0.3'
  gem 'compass', '0.12.alpha.4'
  gem 'fancy-buttons'
end

gem 'jquery-rails'
gem 'therubyracer', :require => 'v8'

gem 'haml'

gem 'rake'

gem 'will_paginate'
gem 'teambox-permalink_fu', :git => 'git://github.com/mconf/permalink_fu.git'
gem 'vpim'
gem 'ruby-openid'
gem 'atom-tools'
gem 'rcov'
gem 'chronic'
gem 'hpricot'
gem 'feed-normalizer'
gem 'hoe'
gem 'httparty'
gem 'pdf-writer'
gem 'ci_reporter'
gem 'nokogiri', '1.4.1'
gem 'prism'
gem 'rubyzip' # TODO: see rubyzip2
gem 'garb'
gem 'galetahub-simple_captcha', :require => 'simple_captcha'
gem 'rmagick', :git => 'git://github.com/rmagick/rmagick.git', :require => false
gem 'fckeditor'
gem 'dynamic_form'
gem 'bigbluebutton-api-ruby', :git => 'git://github.com/mconf/bigbluebutton-api-ruby.git'
gem 'bigbluebutton_rails', :git => 'git://github.com/mconf/bigbluebutton_rails.git'
gem 'action_mailer_tls'
gem 'attachment_fu', :git => 'git://github.com/mconf/attachment_fu.git'
gem 'yaml_db'
gem 'delayed_job_active_record'
gem 'rails_autolink'
gem 'whenever', :require => false

gem 'mysql2', '~> 0.3.0'

# not the official repo, but has fixes to use it with rails 3
# TODO: remove or update
gem 'table_helper', :git => 'git://github.com/eeng/table_helper.git'

group :development do
  #gem 'ruby-debug19', :require => 'ruby-debug'
  gem 'capistrano', '~> 2.5'
  gem 'capistrano-ext'
  gem 'translate-rails3', :require => 'translate', :git => 'git://github.com/mconf/translate.git'
end

group :development, :test do
  gem 'rspec-rails', '>= 2.5'
  gem 'populator'
  gem 'ffaker'
  gem 'factory_girl'
  gem 'sqlite3'
  gem 'webrat'
  gem 'rspec-instafail'
  gem 'fuubar'
  gem 'shoulda-matchers'
  gem 'htmlentities'
  gem 'turn', '0.8.2', :require => false
end

group :production do
  gem 'god', '0.11.0'
  gem 'passenger', '3.0.7'
  gem 'exception_notification'
end

# Rails 3.1 - Heroku
#group :production do
#  gem 'therubyracer-heroku', '0.8.1.pre3'
#  gem 'pg'
#end
