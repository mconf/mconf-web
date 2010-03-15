set :servers,  {
  :production => 'isabel@vcc.dit.upm.es',
  :test => 'isabel@vcc-test.dit.upm.es',
  :gplaza => 'isabel@138.4.17.137'
}

set :branches, {
  :production => :stable,
  :test => :master,
  :gplaza => :master
}

set :environment, :test

set :application, "global2"
set :repository,  "http://git-isabel.dit.upm.es/global2.git"
set :scm, "git"
set :git_enable_submodules, 1
set :use_sudo, false

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/home/isabel/#{ application }"
set :deploy_via, :export

role(:app) { ENV['SERVER'] || fetch(:servers)[fetch(:environment)] }
role(:web) { ENV['SERVER'] || fetch(:servers)[fetch(:environment)] }
role(:db, :primary => true) { ENV['SERVER'] || fetch(:servers)[fetch(:environment)] }

set(:branch) { ENV['BRANCH'] || fetch(:branches)[fetch(:environment)]}

before 'deploy:migrations', 'vcc:info'
before 'deploy:setup', 'vcc:info'
after 'deploy:update_code', 'deploy:link_files'
after 'deploy:update_code', 'deploy:fix_file_permissions'
after 'deploy:restart', 'deploy:reload_ultrasphinx'

namespace(:deploy) do
  task :fix_file_permissions do
    # AttachmentFu dir is deleted in deployment
    run  "/bin/mkdir -p #{ release_path }/tmp/attachment_fu"
    run "/bin/chmod -R g+w #{ release_path }/tmp"
    sudo "/bin/chgrp -R www-data #{ release_path }/tmp"
    sudo "/bin/chgrp -R www-data #{ release_path }/log/production.log"
    run "/bin/chmod g+w #{ release_path }/log/production.log"
    sudo "/bin/chgrp -R www-data #{ release_path }/public/images/tmp"
    sudo "/bin/mkdir -p /opt/local"
    sudo "/bin/chgrp -R www-data /opt/local"
    sudo "/bin/chmod g+w /opt/local"
  end

  task :link_files do
    run "ln -sf #{ shared_path }/config/database.yml #{ release_path }/config/"
    run "ln -sf #{ shared_path }/config/ultrasphinx #{ release_path }/config/"
    run "ln -sf #{ shared_path }/public/logos #{ release_path }/public"
    run "ln -sf #{ shared_path }/attachments #{ release_path }/attachments"
  end

  desc "Restarting mod_rails with restart.txt"
    task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

  task :reload_ultrasphinx do
    run "cd #{ current_path } && rake ultrasphinx:configure RAILS_ENV=production"
    run "cd #{ current_path } && sudo /usr/bin/rake ultrasphinx:index RAILS_ENV=production"
    run "sudo /etc/init.d/sphinxsearch restart"
  end
end

namespace(:vcc) do

  task :info do
    puts "Deploying SERVER = #{ ENV['SERVER'] || fetch(:servers)[fetch(:environment)]}"
    puts "Deploying BRANCH = #{ ENV['BRANCH'] || fetch(:branches)[fetch(:environment)]}"
  end
  
  task :production do
    set :environment, :production
    deploy.migrations
  end
  
  task :gplaza do
    set :environment, :gplaza
    deploy.migrations
  end
  
  task :default do
    deploy.migrations
  end
end


