# Resque tasks
require 'resque/tasks'
require 'resque/scheduler/tasks'
require 'logger'

task "resque:setup" => :environment

namespace :resque do
  task :setup do
    require 'resque'
    require 'resque-scheduler'
  end
end
