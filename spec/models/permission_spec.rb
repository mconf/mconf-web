# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe Permission do

  it { should belong_to(:user) }
  it { should belong_to(:subject) }
  it { should belong_to(:role) }

  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:subject) }
  it { should validate_presence_of(:role) }
  it { should validate_presence_of(:role_id) }

  # Having 2 problems with this section
  it "validate_uniqueness of role_id" do
    # This next line is here because of http://stackoverflow.com/a/20791806/414642
    # FactoryGirl.create(:space_permission)
    # Here I get this bug https://github.com/thoughtbot/shoulda-matchers/issues/203
    # should validate_uniqueness_of(:role_id).scoped_to(:user_id, :subject_id, :subject_type)
  end

  describe "abilities", :abilities => true do
    subject { ability }
    let(:ability) { Abilities.ability_for(user) }

    context "for the subject Space" do
      let(:space) { FactoryGirl.create(:space) }
      let(:other_user) { FactoryGirl.create(:user) }

      context "when is an anonymous user" do
        let(:user) { User.new }
        let(:target) { FactoryGirl.create(:space_permission) }
        it { should_not be_able_to_do_anything_to(target) }
      end

      context "when is a registered user" do
        let(:user) { FactoryGirl.create(:user) }

        context "that's not a member of the permission's space" do
          let(:target) { FactoryGirl.create(:space_permission) }
          it { should_not be_able_to_do_anything_to(target).except(:index) }
        end

        context "that's a normal member of the permission's space" do
          before {
            space.add_member!(other_user)
            space.add_member!(user)
          }
          it { should_not be_able_to_do_anything_to(Permission.find_by(subject: space, user: user)).except(:index) }
          it { should_not be_able_to_do_anything_to(Permission.find_by(subject: space, user: other_user)).except(:index) }
        end

        context "that's an admin of the permission's space" do
          before {
            space.add_member!(other_user, 'Admin')
            space.add_member!(user, 'Admin')
          }
          it {
            should_not be_able_to_do_anything_to(Permission.find_by(subject: space, user: user))
              .except([:show, :edit, :update, :destroy, :index])
          }
          it {
            should_not be_able_to_do_anything_to(Permission.find_by(subject: space, user: other_user))
              .except([:show, :edit, :update, :destroy, :index])
          }
        end

        context "that's the last admin of the permission's space" do
          before {
            space.add_member!(user, 'Admin')
            space.add_member!(other_user, 'User')
          }
          it {
            should_not be_able_to_do_anything_to(Permission.find_by(subject: space, user: user))
              .except([:show, :edit, :index])
          }
          it {
            should_not be_able_to_do_anything_to(Permission.find_by(subject: space, user: other_user))
              .except([:show, :edit, :update, :destroy, :index])
          }
        end
      end

      context "when is a superuser" do
        let(:user) { FactoryGirl.create(:superuser) }

        context "that's not a member of the permission's space" do
          let(:target) { FactoryGirl.create(:space_permission) }
          it { should be_able_to_do_everything_to(target) }
        end

        context "that's a normal member of the permission's space" do
          before {
            space.add_member!(other_user)
            space.add_member!(user)
          }
          it { should be_able_to_do_everything_to(Permission.find_by(subject: space, user: user)) }
          it { should be_able_to_do_everything_to(Permission.find_by(subject: space, user: other_user)) }
        end

        context "that's an admin of the permission's space" do
          before {
            space.add_member!(other_user, 'Admin')
            space.add_member!(user, 'Admin')
          }
          it { should be_able_to_do_everything_to(Permission.find_by(subject: space, user: user)) }
          it { should be_able_to_do_everything_to(Permission.find_by(subject: space, user: other_user)) }
        end

        context "that's the last admin of the permission's space" do
          before {
            space.add_member!(user, 'Admin')
            space.add_member!(other_user, 'User')
          }
          it {
            should_not be_able_to_do_anything_to(Permission.find_by(subject: space, user: user))
              .except([:create, :edit, :index, :manage, :new, :show, :index])
          }
          it { should be_able_to_do_everything_to(Permission.find_by(subject: space, user: other_user)) }
        end

      end
    end
  end
end
