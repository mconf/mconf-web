namespace :setup do
  namespace :basic_data do
    desc "Reload basic data"
    task :reload => [ :clear, :all ]

    desc "Reset the database"
    task :clear => "db:reset"

    desc "Load all basic data"
    task :all => [ :users, :spaces, :roles ]

    desc "Load Basic data in test"
    task :test => "db:test:prepare" do
      ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations['test'])
      ActiveRecord::Schema.verbose = false
      Rake::Task["setup:basic_data:all"].invoke
    end

    desc "Load Users Data"
    task :users => :environment do
      puts "* Create Administrator \"vcc\""
      u = User.create :login => "vcc",
                      :email => 'vcc@dit.upm.es',
                      :password => "admin",
                      :password_confirmation => "admin"
      u.update_attribute(:superuser,true)
      u.activate
      u.profile!.update_attribute(:full_name, "Vcc")

    end

    desc "Load Spaces Data"
    task :spaces => :environment do
      puts "* Create Space \"VCC Start Page\""
      Space.create :name => "VCC Start Page",
                   :description => "Virtual Conference Centre (VCC)",
                   :public => true,
                   :default_logo => "models/front/space.png"
    end

    desc "Load Spaces Data"
    task :permissions => :environment do
      puts "* Create Permissions"

      # Permissions without objective
      %w( read update delete translate ).each do |action|
        Permission.find_or_create_by_action_and_objective action, nil
      end

      # Permissions applied to Content and Performance
      %w( create read update delete ).each do |action|
        %w( content performance ).each do |objective|
          Permission.find_or_create_by_action_and_objective action, objective
        end
      end
      
      Permission.find_or_create_by_action_and_objective "update", "attachment"

      # Permission applied to Group
      Permission.find_or_create_by_action_and_objective "manage", "group"
      # Permission to start an event
      Permission.find_or_create_by_action_and_objective "start", "event"
    end

    desc "Load Roles Data"
    task :roles => :permissions do
      puts "* Create Roles"
      translator_role = Role.find_or_create_by_name_and_stage_type "Translator", "Site"
      translator_role.permissions << Permission.find_by_action_and_objective('translate', nil)

      organizer_role = Role.find_or_create_by_name_and_stage_type "Organizer", "Event"
      organizer_role.permissions << Permission.find_by_action_and_objective('read', nil)
      organizer_role.permissions << Permission.find_by_action_and_objective('update', nil)
      organizer_role.permissions << Permission.find_by_action_and_objective('create', 'content')
      organizer_role.permissions << Permission.find_by_action_and_objective('read',   'content')
      organizer_role.permissions << Permission.find_by_action_and_objective('update', 'content')
      organizer_role.permissions << Permission.find_by_action_and_objective('delete', 'content')
      organizer_role.permissions << Permission.find_by_action_and_objective('start', 'event')
      
      invitedevent_role = Role.find_or_create_by_name_and_stage_type "Invitedevent", "Event"
      invitedevent_role.permissions << Permission.find_by_action_and_objective('read', nil)
      
      speaker_role = Role.find_or_create_by_name_and_stage_type "Speaker", "AgendaEntry"
      speaker_role.permissions << Permission.find_by_action_and_objective('read', nil)
      speaker_role.permissions << Permission.find_by_action_and_objective('update', nil)
      

      admin_role = Role.find_or_create_by_name_and_stage_type "Admin", "Space"
      admin_role.permissions << Permission.find_by_action_and_objective('read',   nil)
      admin_role.permissions << Permission.find_by_action_and_objective('update', nil)
      admin_role.permissions << Permission.find_by_action_and_objective('delete', nil)
      admin_role.permissions << Permission.find_by_action_and_objective('create', 'content')
      admin_role.permissions << Permission.find_by_action_and_objective('read',   'content')
      admin_role.permissions << Permission.find_by_action_and_objective('update', 'content')
      admin_role.permissions << Permission.find_by_action_and_objective('delete', 'content')
      admin_role.permissions << Permission.find_by_action_and_objective('create', 'performance')
      admin_role.permissions << Permission.find_by_action_and_objective('read',   'performance')
      admin_role.permissions << Permission.find_by_action_and_objective('update', 'performance')
      admin_role.permissions << Permission.find_by_action_and_objective('delete', 'performance')
      admin_role.permissions << Permission.find_by_action_and_objective('manage', 'group')

      user_role = Role.find_or_create_by_name_and_stage_type "User", "Space"
      user_role.permissions << Permission.find_by_action_and_objective('read',   nil)
      user_role.permissions << Permission.find_by_action_and_objective('create', 'content')
      user_role.permissions << Permission.find_by_action_and_objective('read',   'content')
      user_role.permissions << Permission.find_by_action_and_objective('update', 'attachment')
      user_role.permissions << Permission.find_by_action_and_objective('create', 'performance')
      user_role.permissions << Permission.find_by_action_and_objective('read',   'performance')

      invited_role = Role.find_or_create_by_name_and_stage_type "Invited", "Space"
      invited_role.permissions << Permission.find_by_action_and_objective('read', nil)
      invited_role.permissions << Permission.find_by_action_and_objective('read', 'content')
      invited_role.permissions << Permission.find_by_action_and_objective('read', 'performance')
    end
  end
end
