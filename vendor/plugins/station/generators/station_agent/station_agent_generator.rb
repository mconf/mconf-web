class StationAgentGenerator < Rails::Generator::NamedBase
  default_options :skip_migration => false,
                  :include_activation => false,
                  :allow_collissions => false
                  
  attr_reader   :controller_name,
                :controller_class_path,
                :controller_file_path,
                :controller_class_nesting,
                :controller_class_nesting_depth,
                :controller_class_name,
                :controller_singular_name,
                :controller_plural_name,
                :controller_file_name
  alias_method  :controller_table_name, :controller_plural_name
  attr_reader   :model_controller_name,
                :model_controller_class_path,
                :model_controller_file_path,
                :model_controller_class_nesting,
                :model_controller_class_nesting_depth,
                :model_controller_class_name,
                :model_controller_singular_name,
                :model_controller_plural_name,
                :model_controller_file_name
  alias_method  :model_controller_table_name, :model_controller_plural_name

  def initialize(runtime_args, runtime_options = {})
    super
    
    @rspec = has_rspec?

    @controller_name = args.shift || 'sessions'
    @model_controller_name = @name.pluralize

    # sessions controller
    base_name, @controller_class_path, @controller_file_path, @controller_class_nesting, @controller_class_nesting_depth = extract_modules(@controller_name)
    @controller_class_name_without_nesting, @controller_file_name, @controller_plural_name = inflect_names(base_name)
    @controller_singular_name = @controller_file_name.singularize

    if @controller_class_nesting.empty?
      @controller_class_name = @controller_class_name_without_nesting
    else
      @controller_class_name = "#{@controller_class_nesting}::#{@controller_class_name_without_nesting}"
    end

    # model controller
    base_name, @model_controller_class_path, @model_controller_file_path, @model_controller_class_nesting, @model_controller_class_nesting_depth = extract_modules(@model_controller_name)
    @model_controller_class_name_without_nesting, @model_controller_file_name, @model_controller_plural_name = inflect_names(base_name)
    @model_controller_singular_name = @model_controller_file_name.singularize
    
    if @model_controller_class_nesting.empty?
      @model_controller_class_name = @model_controller_class_name_without_nesting
    else
      @model_controller_class_name = "#{@model_controller_class_nesting}::#{@model_controller_class_name_without_nesting}"
    end
  end

  def manifest
    recorded_session = record do |m|
      unless options[:allow_collissions]
        # Check for class naming collisions.
        m.class_collisions controller_class_path,       "#{controller_class_name}Controller", # Sessions Controller
                                                        "#{controller_class_name}Helper"
        m.class_collisions model_controller_class_path, "#{model_controller_class_name}Controller", # Model Controller
                                                        "#{model_controller_class_name}Helper"
        m.class_collisions class_path,                  "#{class_name}", "#{class_name}Mailer", "#{class_name}MailerTest", "#{class_name}Observer"
      end

      # Controller, helper, views, and test directories.
      m.directory File.join('app/models', class_path)
      m.directory File.join('app/controllers', model_controller_class_path)
      m.directory File.join('app/helpers', controller_class_path)
      m.directory File.join('app/views', class_path, "#{file_name}_mailer")

      m.directory File.join('app/controllers', model_controller_class_path)
      m.directory File.join('app/helpers', model_controller_class_path)
      m.directory File.join('app/views', model_controller_class_path, model_controller_file_name)

      if @rspec
        m.directory File.join('spec/controllers', controller_class_path)
        m.directory File.join('spec/controllers', model_controller_class_path)
        m.directory File.join('spec/models', class_path)
        m.directory File.join('spec/fixtures', class_path)
      else
        m.directory File.join('test/functional', controller_class_path)
        m.directory File.join('test/functional', model_controller_class_path)
        m.directory File.join('test/unit', class_path)
      end

      m.template 'model.rb',
                  File.join('app/models',
                            class_path,
                            "#{file_name}.rb")

      %w( mailer observer ).each do |model_type|
        m.template "#{model_type}.rb", File.join('app/models',
                                             class_path,
                                             "#{file_name}_#{model_type}.rb")
      end

      m.template 'model_controller.rb',
                  File.join('app/controllers',
                            model_controller_class_path,
                            "#{model_controller_file_name}_controller.rb")

      if @rspec
        m.template 'functional_spec.rb',
                    File.join('spec/controllers',
                              controller_class_path,
                              "#{controller_file_name}_controller_spec.rb")
        m.template 'model_functional_spec.rb',
                    File.join('spec/controllers',
                              model_controller_class_path,
                              "#{model_controller_file_name}_controller_spec.rb")
        m.template 'unit_spec.rb',
                    File.join('spec/models',
                              class_path,
                              "#{file_name}_spec.rb")
        m.template 'fixtures.yml',
                    File.join('spec/fixtures',
                              "#{table_name}.yml")
      else
        m.template 'functional_test.rb',
                    File.join('test/functional',
                              controller_class_path,
                              "#{controller_file_name}_controller_test.rb")
        m.template 'model_functional_test.rb',
                    File.join('test/functional',
                              model_controller_class_path,
                              "#{model_controller_file_name}_controller_test.rb")
        m.template 'unit_test.rb',
                    File.join('test/unit',
                              class_path,
                              "#{file_name}_test.rb")
        m.template 'mailer_test.rb', File.join('test/unit', class_path, "#{file_name}_mailer_test.rb")
        m.template 'fixtures.yml',
                    File.join('test/fixtures',
                              "#{table_name}.yml")
      end

      m.template 'helper.rb',
                  File.join('app/helpers',
                            controller_class_path,
                            "#{controller_file_name}_helper.rb")

      m.template 'model_helper.rb',
                  File.join('app/helpers',
                            model_controller_class_path,
                            "#{model_controller_file_name}_helper.rb")


      # Controller templates
      m.template 'signup.html.erb', File.join('app/views', model_controller_class_path, model_controller_file_name, "new.html.erb")

      for action in %w( show.html.erb show.atomsvc.builder show.xrds.builder ) do
        m.template action, File.join('app/views', model_controller_class_path, model_controller_file_name, action)
      end

      %w( lost_password.html.erb reset_password.html.erb ).each do |action|
        m.template action, File.join('app/views', model_controller_class_path, model_controller_file_name, action)
      end

      # Mailer templates
      %w( signup_notification lost_password reset_password ).each do |action|
        m.template "mailer_#{action}.text.plain.erb",
                   File.join('app/views', "#{file_name}_mailer", "#{action}.html.erb")
      end

      if options[:include_activation]
        # Mailer templates
        %w( activation ).each do |action|
          m.template "mailer_#{action}.text.plain.erb",
                     File.join('app/views', "#{file_name}_mailer", "#{action}.html.erb")
        end
      end

      unless options[:skip_migration]
        m.migration_template 'migration.rb', 'db/migrate', :assigns => {
          :migration_name => "Create#{class_name.pluralize.gsub(/::/, '')}"
        }, :migration_file_name => "create_#{file_path.gsub(/\//, '_').pluralize}"
      end
    end

    action = nil
    action = $0.split("/")[1]
    case action
      when "generate" 
        puts
        puts ("-" * 70)
        puts "You have these default routes available:"
        puts "(see vendor/plugins/station/config/routes.rb)"
        puts
        puts %(map.login '/login', :controller => '#{controller_file_name}', :action => 'new')
        puts %(map.logout '/logout', :controller => '#{controller_file_name}', :action => 'destroy')
          puts %(map.lost_password '/lost_password', :controller => '#{model_controller_file_name}', :action => 'lost_password')
          puts %(map.reset_password '/reset_password/:reset_password_code', :controller => '#{model_controller_file_name}', :action => 'reset_password')
         if options[:include_activation]
          puts %(map.activate '/activate/:activation_code', :controller => '#{model_controller_file_name}', :action => 'activate')
         puts
          puts "Don't forget to:"
          puts "  - add an observer to config/environment.rb"
          puts "    config.active_record.observers = :#{file_name}_observer"
          puts
        end
        puts
        puts ("-" * 70)
        puts
      when "destroy" 
        puts
        puts ("-" * 70)
        puts
        puts "Don't forget to comment out the observer line in environment.rb"
        puts "  (This was optional so it may not even be there)"
        puts "  # config.active_record.observers = :#{file_name}_observer"
        puts
        puts ("-" * 70)
        puts
      else
        puts
    end

    recorded_session
  end

  def has_rspec?
    options[:rspec] || (File.exist?('spec') && File.directory?('spec'))
  end
  
  protected
    # Override with your own usage banner.
    def banner
      "Usage: #{$0} station_agent ModelName [ControllerName]"
    end

    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      opt.on("--skip-migration", 
             "Don't generate a migration file for this model") { |v| options[:skip_migration] = true }
      opt.on("--include-activation", 
             "Generate signup 'activation code' confirmation via email") { |v| options[:include_activation] = true }
      opt.on("--allow-collissions", 
             "Don't check for class collissions") { |v| options[:allow_collissions] = true }
      opt.on("--rspec",
             "Force rspec mode (checks for RAILS_ROOT/spec by default)") { |v| options[:rspec] = true }
    end
end
