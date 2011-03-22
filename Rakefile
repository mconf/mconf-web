# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.
require 'rubygems'
require 'bundler/setup'
require 'rspec/core/rake_task'

require File.expand_path('../config/application', __FILE__)
require 'rake'

desc 'Default: run tests.'
task :default => :spec

RSpec::Core::RakeTask.new(:spec)

Vcc::Application.load_tasks
