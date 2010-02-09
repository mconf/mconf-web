namespace :setup do
  desc "Set production environment and run all production tasks"
  task :production do
    RAILS_ENV = ENV['RAILS_ENV'] = 'production'
    Rake::Task["setup:production_tasks"].invoke
  end

  desc "Setup development environment"
  task :development => [ :development_tasks, :production_tasks, :populate ] do
  end

  desc "All development tasks"
  task :development_tasks => [ ]

  desc "All production tasks"
  task :production_tasks => [ :config_cron, :config_ultrasphinx, :git_submodules, "db:schema:load", "basic_data:all" ] do
  end

  desc "Copy cron.d/vcc if it doesn't exist"
  task :config_cron do
    print "* Checking /etc/cron.d/vcc: "
    cron_file = "/etc/cron.d/vcc"

    if File.exist?(cron_file)
      puts "file exists."
    else
      `sudo cp #{ RAILS_ROOOT }/extras/cron/vcc #{ cron_file }` 
      puts "copied."
    end
  end

  desc "Copy config/ultrasphinx if it doesn't exist"
  task :config_ultrasphinx do
    print "* Checking config/ultrasphinx: "
    u_dir = "#{ RAILS_ROOT }/config/ultrasphinx"

    if File.exist?(u_dir)
      puts "directory exists."
    else
      `cp -r #{ u_dir }.example #{ u_dir }` 
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
