namespace :setup do
  namespace :basic_data do
    desc "Load all basic data"
    task :all => [ :users, :performances ]

    desc "Load Users Data"
    task :users => :environment do
      puts "* Create Administrator \"vcc\""
      User.create :login => "vcc",
                  :email => 'vcc@dit.upm.es',
                  :password => "admin",
                  :password_confirmation => "admin",
                  :superuser => true,
                  :activated_at => Time.now,
                  :activation_code => nil
    end

    desc "Load Spaces Data"
    task :spaces => :environment do
      puts "* Create Space \"VCC Start Page\""
      Space.create :name => "VCC Start Page",
                   :description => "Virtual Conference Centre (VCC)",
                   :public => true
    end

    desc "Load Spaces Data"
    task :permissions => :environment do
      puts "* Create Permissions"

      # Permissions applied to self
      %w( read update delete ).each do |action|
        Permission.find_or_create_by_action_and_objective action, "self"
      end

      # Permissions applied to Content and Performance
      %w( create read update delete ).each do |action|
        %w( Content Performance ).each do |objective|
          Permission.find_or_create_by_action_and_objective action, objective
        end
      end
    end

    desc "Load Roles Data"
    task :roles => :permissions do
      puts "* Create Roles"
      admin_role = Role.find_or_create_by_name_and_stage_type "Admin", "Space"
      admin_role.permissions << Permission.find_by_action_and_objective('read',   'self')
      admin_role.permissions << Permission.find_by_action_and_objective('update', 'self')
      admin_role.permissions << Permission.find_by_action_and_objective('delete', 'self')
      admin_role.permissions << Permission.find_by_action_and_objective('create', 'Content')
      admin_role.permissions << Permission.find_by_action_and_objective('read',   'Content')
      admin_role.permissions << Permission.find_by_action_and_objective('update', 'Content')
      admin_role.permissions << Permission.find_by_action_and_objective('delete', 'Content')
      admin_role.permissions << Permission.find_by_action_and_objective('create', 'Performance')
      admin_role.permissions << Permission.find_by_action_and_objective('read',   'Performance')
      admin_role.permissions << Permission.find_by_action_and_objective('update', 'Performance')
      admin_role.permissions << Permission.find_by_action_and_objective('delete', 'Performance')

      user_role = Role.find_or_create_by_name_and_stage_type "User", "Space"
      user_role.permissions << Permission.find_by_action_and_objective('read',   'self')
      user_role.permissions << Permission.find_by_action_and_objective('create', 'Content')
      user_role.permissions << Permission.find_by_action_and_objective('read',   'Content')
      user_role.permissions << Permission.find_by_action_and_objective('create', 'Performance')
      user_role.permissions << Permission.find_by_action_and_objective('read',   'Performance')

      invited_role = Role.find_or_create_by_name_and_stage_type "Invited", "Space"
      invited_role.permissions << Permission.find_by_action_and_objective('read', 'self')
      invited_role.permissions << Permission.find_by_action_and_objective('read', 'Content')
      invited_role.permissions << Permission.find_by_action_and_objective('read', 'Performance')
    end

    desc "Load Performances Data"
    task :performances => [ :roles, :spaces ] do
      Space.find_by_name("VCC Start Page").stage_performances.create :agent => Anyone.current,
      :role => Role.find_by_name_and_stage_type("Invited", "Space")
    end
  end
end
