set :servers,  {
  :production => 'isabel@www.globalplaza.org',
  :test => 'isabel@vcc-test.dit.upm.es'
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
after 'deploy:update_code', 'deploy:copy_openfire_code'
after 'deploy:restart', 'deploy:reload_ultrasphinx'
after 'deploy:restart', 'deploy:reload_openfire'
after 'deploy:setup', 'setup:create_shared'

namespace(:deploy) do
  task :fix_file_permissions do
    # AttachmentFu dir is deleted in deployment
    run  "/bin/mkdir -p #{ release_path }/tmp/attachment_fu"
    run "/bin/chmod -R g+w #{ release_path }/tmp"
    run "/bin/chmod -R g+w #{ release_path }/public/pdf"
    sudo "/bin/chgrp -R www-data #{ release_path }/tmp"
    sudo "/bin/chgrp -R www-data #{ release_path }/public/images/tmp"
    sudo "/bin/chgrp -R www-data #{ release_path }/public/pdf"
    # Allow Translators modify locale files
    sudo "/bin/chgrp -R www-data #{ release_path }/config/locales"
  end

  task :link_files do
    run "ln -sf #{ shared_path }/config/database.yml #{ release_path }/config/"
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
  
  task :copy_openfire_code do
    run "sudo cp #{ release_path }/extras/chat/openfire/installation/vccCustomAuthentication.jar /usr/share/openfire/lib/"
    run "sudo cp #{ release_path }/extras/chat/openfire/installation/vccRooms.jar /usr/share/openfire/plugins/"
  end
  
  task :reload_openfire do
    run "sudo /etc/init.d/openfire restart"
  end
end

namespace(:setup) do
  task :create_shared do
    run "/bin/mkdir -p #{ shared_path }/attachments"
    sudo "/bin/chgrp -R www-data #{ shared_path }/attachments"
    run "/bin/chmod -R g+w #{ shared_path }/attachments"
    run "/bin/mkdir -p #{ shared_path }/config"
    sudo "/bin/chgrp -R www-data #{ shared_path }/config"
    run "/bin/chmod -R g+w #{ shared_path }/config"
    run "/bin/mkdir -p #{ shared_path }/public/logos"
    sudo "/bin/chgrp -R www-data #{ shared_path }/public"
    run "/bin/chmod -R g+w #{ shared_path }/public"
    run "/usr/bin/touch #{ shared_path }/log/production.log"
    sudo "/bin/chgrp -R www-data #{ shared_path }/log"
    run "/bin/chmod -R g+w #{ shared_path }/log"
  end
end

namespace(:vcc) do
  task :info do
    puts "Deploying SERVER = #{ ENV['SERVER'] || fetch(:servers)[fetch(:environment)]}"
    puts "Deploying BRANCH = #{ ENV['BRANCH'] || fetch(:branches)[fetch(:environment)]}"
  end

   task :commit_remote_translations do
    run("cat #{ File.join(current_path, 'REVISION') }") do |channel, stream, data| 
      exit unless system("git checkout #{ data }")
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
  
  task :production do
    set :environment, :production
    if ENV['MERGE_LOCALES'] != 'false'
      commit_remote_translations
    end
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


