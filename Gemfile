source 'http://rubygems.org'
#source "http://gems.github.com"

gem 'rails', '3.0.3'

# for station
#gem 'will_paginate' # gem 'mislav-will_paginate', :source => 'http://gems.github.com/'
#gem 'mislav-will_paginate' # :git => 'git://github.com/mislav/will_paginate.git'
gem "will_paginate", "~> 3.0.pre2"
gem 'exception_notification_rails3'
#gem 'attachment_fu', :git => 'git://github.com/woahdae/attachment_fu.git', :branch => 'rails3' # inst as plugin for now
gem 'permalink_fu'

gem 'rmagick'
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
gem 'simple_captcha', :git => 'git://github.com/galetahub/simple-captcha.git'
gem 'fckeditor'
gem 'dynamic_form'

# not the official repo, but has adjustments to use it in rails 3
gem 'table_helper', :git => 'git://github.com/echen/table_helper.git'

group :development, :test do
  gem 'ruby-debug19', :require => 'ruby-debug'
  gem 'rspec-rails', '~> 2.5'
  gem "capistrano"
  gem 'mongrel', '1.2.0.pre2'
  gem 'populator'
  gem 'ffaker'
  gem 'factory_girl'
  gem 'sqlite3-ruby', :require => 'sqlite3'
  gem 'action_mailer_tls'
  gem 'webrat'
end

group :production do
  gem "mysql"
end
