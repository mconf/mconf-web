# Quick refs:
# (note: you can replace "staging" by "production" to set the target stage, see deploy/conf.yml)
#
#  cap staging setup:all                     # first time setup of a server
#  cap staging deploy:migrations             # update to a new release, run the migrations (i.e. updates the DB) and restart the web server
#  cap staging deploy:udpate                 # update to a new release
#  cap staging deploy:migrate                # run the migrations
#  cap staging deploy:restart                # restart the web server
#  cap staging rake:invoke TASK=jobs:queued  # run a rake task in the remote server
#
#  Other:
#  cap staging deploy:web:disable  # start maintenance mode (the site will be offline)
#  cap staging deploy:web:enable   # stop maintenance mode (the site will be online)
#  cap staging deploy:rollback     # go back to the previous version
#  cap staging setup:secret        # creates a new secret token (requires restart)
#  cap staging setup:db            # drops, creates and populates the db with the basic data
#

# RVM bootstrap
$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.
require "rvm/capistrano"
set :rvm_ruby_string, '1.9.2-p290@mconf'

# bundler bootstrap
require 'bundler/capistrano'

# read the configuration file
CONFIG_FILE = File.join(File.dirname(__FILE__), 'deploy', 'conf.yml')
set :configs, YAML.load_file(CONFIG_FILE)

# multistage setup
set :stages, %w(production staging)
require 'capistrano/ext/multistage'

# anti-tty error
default_run_options[:pty] = true

# standard configuration for all stages
set :application, "mconf-web"
set :user, "mconf"
set :deploy_to, "/home/#{fetch(:user)}/#{fetch(:application)}"
set :deploy_via, :remote_cache
set :git_enable_submodules, 1
set :use_sudo, false
set :auto_accept, 0

# whenever integration
set :whenever_command, "bundle exec whenever"
#set :whenever_environment, defer { stage }
require "whenever/capistrano"

after 'multistage:ensure', 'deploy:info'

# DEPLOY tasks
# They are used for each time the app is deployed

after 'deploy:update_code', 'deploy:link_files'
after 'deploy:update_code', 'deploy:upload_config_files'
# after 'deploy:update_code', 'deploy:fix_file_permissions'

namespace :deploy do

  # Nginx tasks
  task(:start) {}
  task(:stop) {}
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path, 'tmp', 'restart.txt')}"
  end

  desc "Prints information about the selected stage"
  task :info do
    puts
    puts "*******************************************************"
    puts "        stage: #{ stage.upcase }"
    puts "       server: #{ fetch(:server) }"
    puts "       branch: #{ fetch(:branch) }"
    puts "   repository: #{ fetch(:repository) }"
    puts "  application: #{ fetch(:application) }"
    puts " release path: #{ release_path }"
    puts "*******************************************************"
    puts
  end

  # Prompt to make really sure we want to deploy into production
  # By http://www.pastbedti.me/2009/01/handling-a-staging-environment-with-capistrano-rails/
  desc "Confirm if the deployment should proceed"
  task :confirm do
    puts "\n\e[0;31m"
    puts "   ######################################################################"
    puts "          Are you REALLY sure you want to deploy to #{stage.upcase} ?"
    puts "           Enter [y/Y] to continue or anything else to cancel"
    puts "   ######################################################################"
    puts "\e[0m\n"
    if fetch(:auto_accept) == 0
      proceed = STDIN.gets[0..0] rescue nil
      unless proceed == 'y' || proceed == 'Y'
        puts "Aborting..."
        exit
      end
    end
  end

  # User uploaded files are stored in the shared folder
  task :link_files do
    run "ln -sf #{shared_path}/public/logos #{release_path}/public"
    run "ln -sf #{shared_path}/attachments #{release_path}/attachments"
    run "ln -sf #{shared_path}/public/scorm #{release_path}/public"
    run "ln -sf #{shared_path}/public/pdf #{release_path}/public"
  end

  desc "Send to the server the local configuration files"
  task :upload_config_files do
    top.upload "config/database.yml", "#{release_path}/config/", :via => :scp
    top.upload "config/setup_conf.yml", "#{release_path}/config/", :via => :scp
    top.upload "config/analytics_conf.yml", "#{release_path}/config/", :via => :scp
  end

end


# SETUP tasks
# They are usually used only once when the application is being set up for the
# first time and affect the database or important setup files

after 'deploy:setup', 'setup:create_shared'

namespace :setup do

  desc "Setup a server for the first time"
  task :all do
    top.deploy.setup      # basic setup of directories
    top.deploy.update     # clone git repo and make it the current release
    setup.db              # destroys and recreates the DB
    setup.secret          # new secret
    setup.statistics      # start the statistics
    top.deploy.restart    # restart the server
  end

  desc "recreates the DB and populates it with the basic data"
  task :db do
    run "cd #{ current_path } && #{try_sudo} bundle exec rake setup:db RAILS_ENV=production"
  end

  # User uploaded files are stored in the shared folder
  task :create_shared do
    run "/bin/mkdir -p #{shared_path}/attachments"
    sudo "/bin/chgrp -R #{fetch(:user)} #{shared_path}/attachments"
    run "/bin/chmod -R g+w #{shared_path}/attachments"
    run "/bin/mkdir -p #{shared_path}/config"
    sudo "/bin/chgrp -R #{fetch(:user)} #{shared_path}/config"
    run "/bin/chmod -R g+w #{shared_path}/config"
    run "/bin/mkdir -p #{shared_path}/public/logos"
    sudo "/bin/chgrp -R #{fetch(:user)} #{shared_path}/public"
    run "/bin/chmod -R g+w #{shared_path}/public"
    run "/usr/bin/touch #{shared_path}/log/production.log"
    sudo "/bin/chgrp -R #{fetch(:user)} #{shared_path}/log"
    run "/bin/chmod -R g+w #{shared_path}/log"
  end

  desc "Creates a new secret in config/initializers/secret_token.rb"
  task :secret do
    run "cd #{current_path} && rake setup:secret RAILS_ENV=production"
    puts "You must restart the server to enable the new secret"
  end

  desc "Creates the Statistic table - needs config/analytics_conf.yml"
  task :statistics do
    run "cd #{current_path} && rake mconf:statistics:init RAILS_ENV=production"
  end
end

namespace :db do
  task :pull do
    run "cd #{current_release} && RAILS_ENV=production bundle exec rake db:data:dump"
    download "#{current_release}/db/data.yml", "db/data.yml"
    `bundle exec rake db:reset db:data:load`
  end
end

# From: http://stackoverflow.com/questions/312214/how-do-i-run-a-rake-task-from-capistrano
namespace :rake do
  desc "Run a task on a remote server."
  # example: cap staging rake:invoke task=jobs:queued
  task :invoke do
    run("cd #{deploy_to}/current; bundle exec rake #{ENV['TASK']} RAILS_ENV=production")
  end
end
