# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
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

  # Make sure to test in controller
  # it { should allow_mass_assignment_of(:role_id) }

  describe "abilities", :abilities => true do
    subject { ability }
    let(:ability) { Abilities.ability_for(user) }

    shared_examples_for "for all permission types" do |exceptions|
      [:space_permission].each do |permission_type|
        let(:target) { FactoryGirl.create(permission_type) }
        it "a '#{permission_type}'" do
          exceptions ||= []
          ability_check()
        end
      end
    end

    context "when is an anonymous user" do
      let(:user) { User.new }
      let(:ability_check) {
        should_not be_able_to_do_anything_to(target)
      }
      it_should_behave_like "for all permission types"
    end

    context "when is a registered user" do
      let(:user) { FactoryGirl.create(:user) }

      context "that's not a member of the permission's space" do
        let(:ability_check) {
          should_not be_able_to_do_anything_to(target)
        }
        it_should_behave_like "for all permission types"
      end

      context "that's a normal member of the permission's space" do
        before {
          case target.subject_type
          when "Space"
            target.subject.add_member!(user)
          end
        }
        let(:ability_check) {
          should_not be_able_to_do_anything_to(target)
        }
        it_should_behave_like "for all permission types"
      end

      context "that's an admin of the permission's space" do
        before {
          case target.subject_type
          when "Space"
            target.subject.add_member!(user, "Admin")
          end
        }
        let(:ability_check) {
          should_not be_able_to_do_anything_to(target).except([:read, :edit, :update])
        }
        it_should_behave_like "for all permission types"
      end
    end

    context "when is a superuser" do
      let(:user) { FactoryGirl.create(:superuser) }
      let(:ability_check) { should be_able_to(:manage, target) }
      it_should_behave_like "for all permission types"
    end

  end
end
