source 'http://rubygems.org'
source "http://gems.github.com"

gem 'rails', '3.0.3'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'mysql'

# for station
#gem 'will_paginate' # gem 'mislav-will_paginate', :source => 'http://gems.github.com/'
gem 'mislav-will_paginate' # :git => 'git://github.com/mislav/will_paginate.git'
gem 'exception_notification_rails3'
#gem 'attachment_fu', :git => 'git://github.com/woahdae/attachment_fu.git', :branch => 'rails3' # inst as plugin for now

gem 'rmagick'
gem 'vpim'
gem 'ruby-openid'
gem 'atom-tools'
gem 'rcov'
gem 'chronic'
gem 'hpricot'
gem 'feed-normalizer'
gem 'rspec-rails' #, '1.3.2'
gem 'hoe'
gem 'httparty'
gem 'pdf-writer'
gem 'ci_reporter'
gem 'nokogiri', '1.4.1'
gem 'prism'
gem 'rubyzip' # TODO: see rubyzip2
gem 'garb'
gem 'simple_captcha', :git => 'git://github.com/galetahub/simple-captcha.git'
gem 'fckeditor'

group :development, :test do
# TODO: gem 'ruby-debug19', :require => 'ruby-debug'
#  gem 'rspec', '1.3.1' # TODO
#  gem 'rspec-rails', '1.3.3' # TODO
  gem "capistrano"
  gem 'mongrel', '1.2.0.pre2'
  gem 'populator'
  gem 'ffaker'
  gem 'factory_girl'
  gem 'sqlite3-ruby'
end

group :production do
  gem "mysql"
end
