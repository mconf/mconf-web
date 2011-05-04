namespace :setup do

  desc "Set production environment and run all production tasks"
  task :production do
    RAILS_ENV = ENV['RAILS_ENV'] = 'production'
    Rake::Task["setup:production_tasks"].invoke
  end

  desc "Setup development environment"
  task :development  do
    RAILS_ENV = ENV['RAILS_ENV'] = 'development'
    Rake::Task["setup:development_tasks"].invoke
  end

  desc "Setup test environment"
  task :test do
    RAILS_ENV = ENV['RAILS_ENV'] = 'test'
    Rake::Task["setup:test_tasks"].invoke
  end


  desc "All development tasks"
  task :development_tasks => [ :common_tasks, :populate ]

  desc "All production tasks"
  #task :production_tasks => [ :config_cron, :config_logrotate, :config_awstats, :common_tasks, :config_sphinx ]
  task :production_tasks => [ :common_tasks ]

  desc "All test tasks"
  task :test_tasks => [ "db:test:prepare", "setup:basic_data:test" ]


  desc "All common tasks"
  #task :common_tasks => [ :git_submodules, "db:schema:load", "basic_data:all", :config_mailing_list_dir ] do
  task :common_tasks => [ :git_submodules, "db:drop", "db:create", "db:migrate", "setup:basic_data:all" ]

  desc "Update Git Submodules"
  task :git_submodules do
    puts "* Updating Git submodules"

    system "git submodule init"
    system "git submodule update"
  end

=begin
  #TODO rails 3: ultrasphinx
  desc "Link /etc/sphinxsearch/sphinx.conf to current/config/ultrasphinx/production.conf"
  task :config_sphinx do
    print "* Checking /etc/sphinxsearch/sphinx.conf: "
    sphinx_file = "/etc/sphinxsearch/sphinx.conf"

    if File.exist?(sphinx_file)
      puts "file exists."
    else
      `sudo ln -s #{ Rails.root.to_s.gsub(/releases\/\d+/, '') }current/config/ultrasphinx/production.conf #{ sphinx_file }`
      puts "linked."
    end
  end
=end

=begin
  desc "Copy cron.d/vcc if it doesn't exist"
  task :config_cron do
    print "* Checking /etc/cron.d/vcc: "
    cron_file = "/etc/cron.d/vcc"

    if File.exist?(cron_file)
      puts "file exists."
    else
      `sudo cp #{ Rails.root.to_s }/extras/cron/vcc #{ cron_file }`
      puts "copied."
    end
  end
=end

=begin
  desc "Copy logrotate.d/vcc if it doesn't exist"
  task :config_logrotate do
    print "* Checking /etc/logrotate.d/vcc: "
    logrotate_file = "/etc/logrotate.d/vcc"

    if File.exist?(logrotate_file)
      puts "file exists."
    else
      `sudo cp #{ Rails.root.to_s }/extras/logrotate/vcc #{ logrotate_file }`
      puts "copied."
    end
  end
=end

=begin
  desc "Copy awstats configuration files"
  task :config_awstats do
    print "* Checking /etc/awstats/awstats.global-project.eu.conf: "
    aw_file = "/etc/awstats/awstats.global-project.eu.conf"

    if File.exist?(aw_file)
      puts "files exist."
    else
      `sudo cp #{ Rails.root.to_s }/extras/awstats/* /etc/awstats/`
      puts "copied."
    end
  end
=end

=begin
  desc "Creates the directory for mailing lists files"
  task :config_mailing_list_dir do
    `sudo mkdir -p /var/local/global2`
    `sudo chown www-data /var/local/global2`
  end
=end

end
