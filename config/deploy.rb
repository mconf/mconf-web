# Tips:
#
#  cap deploy:all          # first time setup of a server
#  cap deploy:setup        # first setup, create directories
#  cap deploy:udpate       # update a new release
#  cap deploy:migrate      # run migrations
#  cap deploy:restart      # restart Nginx
#  cap deploy:web:disable  # start maintenance mode (the site will be offline)
#  cap deploy:web:enable   # stop maintenance mode (the site will be online)
#  cap setup:db            # drops, creates and populates the db with the basic data
#  cap setup:secret        # creates a new secret token (requires restart)
#
#  SERVER=127.0.0.1 cap deploy   # deploy to a server at 127.0.0.1
#  BRANCH=mybranch cap deploy    # deploy a branch named "mybranch"
#

# RVM bootstrap
$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.
require "rvm/capistrano"
set :rvm_ruby_string, '1.9.2@mconf'
set :rvm_type, :user

# bundler bootstrap
require 'bundler/capistrano'

default_run_options[:pty] = true # anti-tty error

set :server, configatron.deploy.server
set :branch, configatron.deploy.branch

set :application, configatron.deploy.app_name
set :repository, configatron.deploy.repository
set :scm, configatron.deploy.repository_scm
set :git_enable_submodules, 1
set :user, "mconf"
set :files_grp, "mconf"
set :use_sudo, false

role(:app) { ENV['SERVER'] || fetch(:server) }
role(:web) { ENV['SERVER'] || fetch(:server) }
role(:db, :primary => true) { ENV['SERVER'] || fetch(:server) }
set(:branch) { ENV['BRANCH'] || fetch(:branch) }

set :deploy_to, "/home/mconf/#{application}"
set :deploy_via, :remote_cache

on :start, 'deploy:info'

after 'deploy:setup', 'setup:create_shared'
after 'deploy:update_code', 'deploy:link_files'
after 'deploy:update_code', 'deploy:fix_file_permissions'

namespace(:deploy) do

  # Nginx tasks
  task(:start) {}
  task(:stop) {}
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  task :info do
    puts
    puts "Deploying SERVER = #{ ENV['SERVER'] || fetch(:server) }"
    puts "Deploying BRANCH = #{ ENV['BRANCH'] || fetch(:branch) }"
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

  task :upload_config_files do
    top.upload "config/database.yml", "#{release_path}/config/", :via => :scp
    top.upload "config/mail_conf.yml", "#{release_path}/config/", :via => :scp
    #top.upload "config/crossdomain.yml", "#{release_path}/config/", :via => :scp
  end

  desc "Setup a server for the first time"
  task :all do
    deploy.setup      # basic setup of directories
    deploy.update     # clone git repo and make it the current release
    top.setup.db      # destroys and recreates the DB
    top.setup.secret  # new secret
  end

end

namespace :setup do

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

  # Creates a new secret in config/initializers/secret_token.rb
  task :secret do
    run "rake setup:secret"
    puts "You must restart the server to enable the new secret"
  end
end

### from vcc

#after 'deploy:update_code', 'deploy:copy_openfire_code'
#after 'deploy:restart', 'deploy:reload_ultrasphinx'
#after 'deploy:restart', 'deploy:reload_openfire'

=begin
  task :production do
    set :environment, :production
    #if ENV['MERGE_LOCALES'] != 'false'
    #  commit_remote_translations
    #end
    deploy.migrations
  end

  task :testing do
    set :environment, :test
    deploy.migrations
  end
=end

=begin
  #TODO rails 3: ultrasphinx
  task :reload_ultrasphinx do
    run "cd #{ current_path } && rake ultrasphinx:configure RAILS_ENV=production"
    run "cd #{ current_path } && sudo /usr/bin/rake ultrasphinx:index RAILS_ENV=production"
    run "sudo /etc/init.d/sphinxsearch restart"
  end
=end

=begin
  task :copy_openfire_code do
    run "sudo cp #{release_path}/extras/chat/openfire/installation/vccCustomAuthentication.jar /usr/share/openfire/lib/"
    run "sudo cp #{release_path}/extras/chat/openfire/installation/vccRooms.jar /usr/share/openfire/plugins/"
  end

  task :reload_openfire do
    run "sudo /etc/init.d/openfire restart"
  end
=end


=begin
  task :commit_remote_translations do
    run("cat #{ File.join(current_path, 'REVISION') }") do |channel, stream, data|
      exit unless system("git checkout #{ data }")
      system("git submodule update")
    end

    # Get remote translations in production server
    get File.join(current_path, "config", "locales"),
        "config/locales", :recursive => true
    # Remove log
    system "rm -r config/locales/log"

    # Commit translations
    system "git commit config/locales -m \"Merge translations in production server\""

    translations_commit = `cat .git/HEAD`.chomp

    # Go to deployment branch
    system "git checkout #{ ENV['BRANCH'] || fetch(:branches)[fetch(:environment)] }"
    system "git submodule update"

    # Add translations commit
    commit = `git cherry-pick #{ translations_commit } 2>&1`

    unless commit =~ /Finished one cherry\-pick/
      puts "There were problems when merging translations"
      puts "Resolve the conflicts, commit and push"
      puts "Then, deploy with MERGE_LOCALES=false"
      puts commit

      exit
    end

    unless system("git push origin #{ ENV['BRANCH'] || fetch(:branches)[fetch(:environment)] }")
      puts "Unable to push to origin"
      exit
    end
  end
=end
