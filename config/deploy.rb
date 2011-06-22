# Quick refs:
# (note: you can replace "staging" by "production" to set the target stage, see deploy/conf.yml)
#
#  cap staging deploy:all          # first time setup of a server
#  cap staging deploy:setup        # first setup, create directories
#  cap staging deploy:udpate       # update a new release
#  cap staging deploy:rollback     # go back to the previous version
#  cap staging deploy:migrate      # run migrations
#  cap staging deploy:restart      # restart Nginx
#  cap staging deploy:web:disable  # start maintenance mode (the site will be offline)
#  cap staging deploy:web:enable   # stop maintenance mode (the site will be online)
#  cap staging setup:db            # drops, creates and populates the db with the basic data
#  cap staging setup:secret        # creates a new secret token (requires restart)
#

# RVM bootstrap
$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.
require "rvm/capistrano"
set :rvm_ruby_string, '1.9.2@mconf'
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
set :deploy_to, "/home/mconf/#{application}"
set :deploy_via, :remote_cache
set :git_enable_submodules, 1
set :user, "mconf"
set :files_grp, "mconf"
set :use_sudo, false

after 'multistage:ensure', 'deploy:info'
after 'deploy:setup', 'setup:create_shared'
after 'deploy:update_code', 'deploy:link_files'
after 'deploy:update_code', 'deploy:upload_config_files'
after 'deploy:update_code', 'deploy:fix_file_permissions'

# Deployment tasks
# Used for each deploy
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

  task :fix_file_permissions do
    run  "/bin/mkdir -p #{release_path}/tmp/attachment_fu" # AttachmentFu dir is deleted in deployment
    run "/bin/chmod -R g+w #{release_path}/tmp"
    sudo "/bin/chgrp -R #{files_grp} #{release_path}/tmp"
    sudo "/bin/chgrp -R #{files_grp} #{release_path}/public/images/tmp"
    sudo "/bin/chgrp -R #{files_grp} #{release_path}/config/locales" # Allow Translators modify locale files
    sudo "/bin/mkdir -p /var/local/mconf-web"
    sudo "/bin/chown #{files_grp} /var/local/mconf-web"
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

# Setup tasks
# They are usually used once in a while and affect the database or important setup files
namespace :setup do

  desc "Setup a server for the first time"
  task :all do
    top.deploy.setup      # basic setup of directories
    top.deploy.update     # clone git repo and make it the current release
    setup.db              # destroys and recreates the DB
    setup.secret          # new secret
  end

  desc "recreates the DB and populates it with the basic data"
  task :db do
    run "cd #{ current_path } && #{try_sudo} bundle exec rake setup:db RAILS_ENV=production"
  end

  task :create_shared do
    run "/bin/mkdir -p #{shared_path}/attachments"
    sudo "/bin/chgrp -R #{files_grp} #{shared_path}/attachments"
    run "/bin/chmod -R g+w #{shared_path}/attachments"
    run "/bin/mkdir -p #{shared_path}/config"
    sudo "/bin/chgrp -R #{files_grp} #{shared_path}/config"
    run "/bin/chmod -R g+w #{shared_path}/config"
    run "/bin/mkdir -p #{shared_path}/public/logos"
    sudo "/bin/chgrp -R #{files_grp} #{shared_path}/public"
    run "/bin/chmod -R g+w #{shared_path}/public"
    run "/usr/bin/touch #{shared_path}/log/production.log"
    sudo "/bin/chgrp -R #{files_grp} #{shared_path}/log"
    run "/bin/chmod -R g+w #{shared_path}/log"
  end

  desc "Creates a new secret in config/initializers/secret_token.rb"
  task :secret do
    run "rake setup:secret"
    puts "You must restart the server to enable the new secret"
  end
end
