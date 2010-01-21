servers = {
  :production => 'isabel@vcc.dit.upm.es',
  :test => 'isabel@vcc-test.dit.upm.es',
  :gplaza => 'isabel@138.4.17.137'
}

default_env = :test
# Set environment
current_env = ( ARGV[1] || default_env ).to_sym


set :application, "global2"
set :repository,  "http://git-isabel.dit.upm.es/global2.git"
set :scm, "git"
set :git_enable_submodules, 1


# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/home/isabel/#{ application }"
set :deploy_via, :export

after 'deploy:update_code', 'deploy:link_files'
after 'deploy:update_code', 'deploy:fix_file_permissions'
after 'deploy:restart', 'deploy:reload_ultrasphinx'

namespace(:deploy) do
  task :fix_file_permissions do
    # AttachmentFu dir is deleted in deployment
    run  "/bin/mkdir -p #{ release_path }/tmp/attachment_fu"
    run "/bin/chmod -R g+w #{ release_path }/tmp"
    sudo "/bin/chgrp -R www-data #{ release_path }/tmp"
    sudo "/bin/chgrp -R www-data #{ release_path }/public/images/tmp"
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
    run "cd #{ current_path } && sudo -u www-data /usr/bin/rake ultrasphinx:index RAILS_ENV=production"
    run "cd #{ current_path } && sudo -u www-data rake ultrasphinx:daemon:restart RAILS_ENV=production"
  end
end


role :app, servers[current_env]
role :web, servers[current_env]
role :db,  servers[current_env], :primary => true

task :vcc do
  deploy.migrations
end
