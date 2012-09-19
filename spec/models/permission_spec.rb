# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe Permission do

  describe "abilities" do
    subject { ability }
    let(:ability) { Abilities.ability_for(user) }

    shared_examples_for "for all permission types" do |exceptions|
      [:space_permission, :event_permission].each do |permission_type|
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

      context "that's not a member of the permission's event space" do
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
          when "Event"
            target.subject.space.add_member!(user)
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
          when "Event"
            target.subject.space.add_member!(user, "Admin")
          end
        }
        let(:ability_check) {
          should_not be_able_to_do_anything_to(target).except([:read, :update])
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
