set :application, "sir2.0"
set :repository,  "http://seta.dit.upm.es/svn/ging/sir2.0/trunk"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/var/www/html/sir.dit.upm.es/sir"
set :deploy_via, :export

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

after 'deploy:update_code', 'deploy:cp_database'
after 'deploy:update_code', 'deploy:fix_file_permissions'

namespace(:deploy) do
  task :fix_file_permissions do
    # AttachmentFu dir is deleted in deployment
    run  "/bin/mkdir -p #{ release_path }/tmp/attachment_fu"
    run "/bin/chmod -R g+w #{ release_path }/tmp"
    run "/bin/chgrp -R www-data #{ release_path }/tmp"
  end

  task :cp_database do
    run "cp #{ release_path }/config/database.yml.example #{ release_path }/config/database.yml"
    run "chgrp www-data #{ release_path }/config/database.yml"
    run "chmod 640 #{ release_path }/config/database.yml"
  end

  desc "Restarting mod_rails with restart.txt"
    task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end
end


role :app, "root@sir.dit.upm.es"
role :web, "root@sir.dit.upm.es"
role :db,  "root@sir.dit.upm.es", :primary => true
