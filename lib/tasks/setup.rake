namespace :setup do
  desc "Set production environment and run all production tasks"
  task :production do
    RAILS_ENV = ENV['RAILS_ENV'] = 'production'
    Rake::Task["setup:production_tasks"].invoke
  end

  desc "Setup development environment"
  task :development => [ :development_tasks, :populate ] do
  end

  desc "All development tasks"
  task :development_tasks => [ :common_tasks ]

  desc "All production tasks"
  task :production_tasks => [ :config_cron, :config_logrotate, :config_awstats, :common_tasks ] do
  end

  desc "All production tasks"
  task :common_tasks => [ :git_submodules, "db:schema:load", "basic_data:all" ] do
  end


  desc "Copy cron.d/vcc if it doesn't exist"
  task :config_cron do
    print "* Checking /etc/cron.d/vcc: "
    cron_file = "/etc/cron.d/vcc"

    if File.exist?(cron_file)
      puts "file exists."
    else
      `sudo cp #{ RAILS_ROOT }/extras/cron/vcc #{ cron_file }` 
      puts "copied."
    end
  end

  desc "Copy logrotate.d/vcc if it doesn't exist"
  task :config_logrotate do
    print "* Checking /etc/logrotate.d/vcc: "
    logrotate_file = "/etc/logrotate.d/vcc"

    if File.exist?(logrotate_file)
      puts "file exists."
    else
      `sudo cp #{ RAILS_ROOT }/extras/logrotate/vcc #{ logrotate_file }` 
      puts "copied."
    end
  end

  desc "Copy awstats configuration files"
  task :config_awstats do
    print "* Checking /etc/awstats/awstats.global-project.eu.conf: "
    aw_file = "/etc/awstats/awstats.global-project.eu.conf"

    if File.exist?(aw_file)
      puts "files exist."
    else
      `sudo cp #{ RAILS_ROOT }/extras/awstats/* /etc/awstats/` 
      puts "copied."
    end
  end


  desc "Update Git Submodules"
  task :git_submodules do
    puts "* Updating Git submodules"

    system "git submodule init"
    system "git submodule update"
  end
end
