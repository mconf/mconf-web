# Overall application setup
# Help you create the basic configuration and setup DB data
# All DB actions will be for the current Rails.env
#
# Examples:
#   rake setup:full                       => run the basic configuration + DB tasks (setup:basic + setup:db)
#   rake setup:basic                      => basic setup: creates configuration files and updates git submodules
#   rake setup:db                         => drops and recreates the DB with all basic data needed
#   rake setup:config                     => create the configuration files (if inexistent -- will not override existent files)
#   RAILS_ENV=production rake setup:full  => first command when setting up a production environment
#   RAILS_ENV=test rake setup:db          => resets your test DB
#
namespace :setup do

  ###############################################################
  # Overall setup
  ###############################################################

  BASIC_TASKS = %w( setup:git_submodules setup:config )
  COMMON_TASKS = %w( db:drop db:create db:migrate db:seed )
  TASKS = {
    :development => COMMON_TASKS, # setup:populate
    :production => COMMON_TASKS,
    :test => %w( db:test:prepare db:seed )
  }

  desc "Full setup, from basic configurations to default DB data creation"
  task :full => [ :basic, :db ]

  desc "Basic setup, including git submodules and config files"
  task :basic do
    run_tasks(BASIC_TASKS)
  end

  desc "DB setup, will destroy your entire DB and recreate it"
  task :db do
    if TASKS[::Rails.env.to_sym].nil?
      puts "Can't proceed: wrong enviroment \"#{::Rails.env}\""
    else
      tasks = TASKS[::Rails.env.to_sym]
      run_tasks(tasks)
    end
  end

  def run_tasks(tasks)
    puts
    puts "Running setup for the environment: " + ::Rails.env
    puts
    tasks.each do |t|
      puts "* Running the task: #{t.to_s}"
      Rake::Task[t.to_s].invoke
    end
  end

  ###############################################################
  # GIT Submodules
  ###############################################################

  desc "Update Git Submodules"
  task :git_submodules do
    puts "* Updating Git submodules"
    system "git submodule init"
    system "git submodule update"
  end

  ###############################################################
  # Configuration files
  ###############################################################

  desc "Setup the configuration files"
  task :config do
    setup_file("config/setup_conf.yml")
    setup_file("config/database.yml")
    setup_file("config/deploy/conf.yml")
  end

  def setup_file(file)
    expanded = File.expand_path(File.join(::Rails.root, file))
    puts "* Checking if \"#{expanded}\" exists..."
    if File.exist?(expanded)
      puts "File exists. You should configure it if you didn't yet."
    else
      `cp #{expanded}.example #{expanded}`
      puts
      puts "*** Created the default configuration file, please edit it: #{file}"
      puts
    end
  end

end
