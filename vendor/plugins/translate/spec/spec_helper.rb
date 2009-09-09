ENV["RAILS_ENV"] = "test"
RAILS_ENV = ENV["RAILS_ENV"]

require 'rubygems'

require File.expand_path(File.dirname(__FILE__) + "/rails_root/config/environment")

require 'spec'
require 'spec/autorun'
require 'spec/rails'

$: << File.expand_path(File.dirname(__FILE__) + '/..')
require 'lib/translate'

Spec::Runner.configure do |config|
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
end
