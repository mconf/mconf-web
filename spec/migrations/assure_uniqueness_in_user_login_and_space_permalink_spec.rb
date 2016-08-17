# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper.rb'
require Rails.root + 'db/migrate/20110807143331_assure_uniqueness_in_user_login_and_space_permalink.rb'

describe AssureUniquenessInUserLoginAndSpacePermalink, :migration => true do
  before do
    @target_migration = 20110807143331
  end

  describe ".up" do

    context "makes User.login's and Space.permalink's unique" do

      context "using with test data" do
        let(:users) {
          [ FactoryGirl.create(:user, :_full_name => "User one"),
            FactoryGirl.create(:user, :_full_name => "User two"),
            FactoryGirl.create(:user, :_full_name => "User three") ]
        }
        let(:spaces) {
          [ FactoryGirl.create(:space, :name => "Space one"),
            FactoryGirl.create(:space, :name => "Space two"),
            FactoryGirl.create(:space, :name => "Space three") ]
        }
        before do
          TestMigrator.migrate_to_previous(@target_migration)

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
      before { TestMigrator.load_data_and_migrate(@target_migration) }

      it do
        User.all.each do |user|
          check_unique_attribute(user).should be_truthy
        end
        Space.all.each do |space|
          check_unique_attribute(space).should be_truthy
        end
      end
    end

  end

end

def check_unique_attribute(model)
  attribute = model.class == Space ? model.permalink : model.login

  spaces = Space.where(:permalink => attribute)
  spaces.select!{ |s| s.id != model.id } if model.class == Space
  users = User.where(:login => attribute)
  users.select!{ |u| u.id != model.id } if model.class == User

  spaces.empty? && users.empty?
end
