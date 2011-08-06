require 'spec_helper.rb'
require Rails.root + 'db/migrate/20110805143331_assure_uniqueness_in_user_login_and_space_permalink.rb'

describe AssureUniquenessInUserLoginAndSpacePermalink, :migration => true do
  before do
    @my_migration_version = 20110805143331
    @previous_migration_version = 20110621154932
  end

  describe ".up" do

    context "makes User.login's and Space.permalink's unique" do

      context "using with test data" do
        let(:users) {
          [ Factory.create(:user, :_full_name => "User one"),
            Factory.create(:user, :_full_name => "User two"),
            Factory.create(:user, :_full_name => "User three") ]
        }
        let(:spaces) {
          [ Factory.create(:space, :name => "Space one"),
            Factory.create(:space, :name => "Space two"),
            Factory.create(:space, :name => "Space three") ]
        }
        before do
          ActiveRecord::Migrator.migrate @previous_migration_version

          # two spaces with permalink duplicated (equal users' logins)
          spaces[0].update_attribute(:permalink, users[0].login)
          spaces[1].update_attribute(:permalink, users[1].login)
          # to conflict with spaces[0] default permalink "space-one"
          users[2].update_attribute(:login, "space-one")

          AssureUniquenessInUserLoginAndSpacePermalink.up
        end

        context "without changing user logins" do
          it { User.find(users[0].id).login.should == users[0].login }
          it { User.find(users[1].id).login.should == users[1].login }
          it { User.find(users[2].id).login.should == users[2].login }
        end

        context "changing spaces' permalinks" do
          it { Space.find(spaces[0].id).permalink.should_not == users[0].login }
          it { Space.find(spaces[1].id).permalink.should_not == users[1].login }
          it { Space.find(spaces[2].id).permalink.should == spaces[2].permalink }
        end

      end

    end

    context "using real data", :migration_real => true do
#      it_should_behave_like "real data migration test" do

      before do
#        ActiveRecord::Migrator.migrate @previous_migration_version
#        system("bundle exec rake db:data:load RAILS_ENV=test")
#        AssureUniquenessInUserLoginAndSpacePermalink.up
        migration_load_real_data(@my_migration_version)
      end

        it do
          User.all.each do |user|
            check_unique_attribute(user).should be_true
          end
          Space.all.each do |space|
            check_unique_attribute(space).should be_true
          end
        end

#      end

    end

  end

end

def migration_load_real_data(migration)

  all_versions = ActiveRecord::Migrator.get_all_versions

  # if not found assumes we're testing the latest migration
  all_versions.include?(migration) ? current_idx = all_versions.index(migration) : current_idx = all_versions.count-1
  previous = current_idx == 0 ? all_versions[0] : all_versions[current_idx-1]

  # rollback, load data then migrate
  ActiveRecord::Migrator.migrate(ActiveRecord::Migrator.migrations_path, previous)
  system("bundle exec rake db:data:load RAILS_ENV=test")
  ActiveRecord::Migrator.up(ActiveRecord::Migrator.migrations_path)

  if ActiveRecord::Migrator.current_version != migration
    puts "It wasn't possible to migrate to the selected migration version"
    puts "  Current version: #{ActiveRecord::Migrator.current_version}"
    puts "  Desired version: #{migration}"
    puts "You probably need to run:"
    puts "  rake db:migrate RAILS_ENV=test"
    exit 1
  end

  true
end

def check_unique_attribute(model)
  attribute = model.class == Space ? model.permalink : model.login

  spaces = Space.where(:permalink => attribute)
  spaces.select!{ |s| s.id != model.id } if model.class == Space
  users = User.where(:login => attribute)
  users.select!{ |u| u.id != model.id } if model.class == User

  spaces.empty? && users.empty?
end






