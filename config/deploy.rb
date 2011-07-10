# Quick refs:
# (note: you can replace "staging" by "production" to set the target stage, see deploy/conf.yml)
#
#  cap staging setup:all           # first time setup of a server
#  cap staging deploy:migrations   # update to a new release, run the migrations (i.e. updates the DB) and restart the web server
#  cap staging deploy:udpate       # update to a new release
#  cap staging deploy:migrate      # run the migrations
#  cap staging deploy:restart      # restart the web server
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
set :rvm_ruby_string, '1.9.2@mconf_production'
set :rvm_type, :user

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

after 'multistage:ensure', 'deploy:info'

# DEPLOY tasks
# They are used for each time the app is deployed

after 'deploy:update_code', 'deploy:link_files'
after 'deploy:update_code', 'deploy:upload_config_files'
after 'deploy:update_code', 'deploy:fix_file_permissions'

namespace :deploy do

  # Nginx tasks
  task(:start) {}
  task(:stop) {}
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
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

  task :fix_file_permissions do
    run  "/bin/mkdir -p #{release_path}/tmp/attachment_fu" # AttachmentFu dir is deleted in deployment
    run "/bin/chmod -R g+w #{release_path}/tmp"
    sudo "/bin/chgrp -R #{fetch(:user)} #{release_path}/tmp"
    sudo "/bin/chgrp -R #{fetch(:user)} #{release_path}/public/images/tmp"
    sudo "/bin/chgrp -R #{fetch(:user)} #{release_path}/config/locales" # Allow Translators modify locale files
    sudo "/bin/mkdir -p /var/local/mconf-web"
    sudo "/bin/chown #{fetch(:user)} /var/local/mconf-web"
  end

  # REVIEW really need to do this?
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
    top.deploy.restart    # restart the server
  end

  desc "recreates the DB and populates it with the basic data"
  task :db do
    run "cd #{ current_path } && #{try_sudo} bundle exec rake setup:db RAILS_ENV=production"
  end

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
end
