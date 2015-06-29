# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe BigbluebuttonRecording do

  # This is a model from BigbluebuttonRails, but we have permissions set in cancan for it,
  # so we test them here.
  describe "abilities", :abilities => true do
    set_custom_ability_actions([:play, :user_show, :user_edit, :space_show, :space_edit])

    subject { ability }
    let(:user) { nil }
    let(:ability) { Abilities.ability_for(user) }

    context "a superuser for a recording", :user => "superuser" do
      let(:user) { FactoryGirl.create(:superuser) }

      context "in his own room" do
        let(:target) { FactoryGirl.create(:bigbluebutton_recording, :room => user.bigbluebutton_room) }
        it { should be_able_to_do_everything_to(target) }
      end

      context "in another user's room" do
        let(:another_user) { FactoryGirl.create(:user) }
        let(:target) { FactoryGirl.create(:bigbluebutton_recording, :room => another_user.bigbluebutton_room) }
        it { should be_able_to_do_everything_to(target) }
      end

      context "in a public space" do
        let(:space) { FactoryGirl.create(:space, :public => true) }
        let(:target) { FactoryGirl.create(:bigbluebutton_recording, :room => space.bigbluebutton_room) }

        context "he doesn't belong to" do
          it { should be_able_to_do_everything_to(target) }
        end

        context "he belongs to" do
          before { space.add_member!(user) }
          it { should be_able_to_do_everything_to(target) }
        end
      end

      context "in a private space" do
        let(:space) { FactoryGirl.create(:space_with_associations, public: false) }
        let(:target) { FactoryGirl.create(:bigbluebutton_recording, :room => space.bigbluebutton_room) }

        context "he doesn't belong to" do
          it { should be_able_to_do_everything_to(target) }
        end

        context "he belongs to" do
          before { space.add_member!(user) }
          it { should be_able_to_do_everything_to(target) }
        end
      end
    end

    context "a normal user for a recording", :user => "normal" do
      let(:user) { FactoryGirl.create(:user) }

      context "in his own room" do
        let(:target) { FactoryGirl.create(:bigbluebutton_recording, :room => user.bigbluebutton_room) }
        let(:allowed) { [:play, :update, :user_show, :user_edit] }
        it { should_not be_able_to_do_anything_to(target).except(allowed) }
      end

      context "in another user's room" do
        let(:another_user) { FactoryGirl.create(:user) }
        let(:target) { FactoryGirl.create(:bigbluebutton_recording, :room => another_user.bigbluebutton_room) }
        it { should_not be_able_to_do_anything_to(target) }
      end

      context "in a public space" do
        let(:space) { FactoryGirl.create(:space_with_associations, public: true) }
        let(:target) { FactoryGirl.create(:bigbluebutton_recording, :room => space.bigbluebutton_room) }

        context "he doesn't belong to" do
          let(:allowed) { [:play, :space_show] }
          it { should_not be_able_to_do_anything_to(target).except(allowed) }
        end

        context "he belongs to" do
          context "as a normal user" do
            before { space.add_member!(user) }
            let(:allowed) { [:play, :space_show] }
            it { should_not be_able_to_do_anything_to(target).except(allowed) }
          end

          context "as an admin" do
            before { space.add_member!(user, 'Admin') }
            let(:allowed) { [:play, :space_show, :update, :space_edit] }
            it { should_not be_able_to_do_anything_to(target).except(allowed) }
          end
        end
      end

      context "in a private space" do
        let(:space) { FactoryGirl.create(:space_with_associations, public: false) }
        let(:target) { FactoryGirl.create(:bigbluebutton_recording, :room => space.bigbluebutton_room) }

        context "he doesn't belong to" do
          it { should_not be_able_to_do_anything_to(target) }
        end

        context "he belongs to" do
          context "as a normal user" do
            before { space.add_member!(user) }
            let(:allowed) { [:play, :space_show] }
            it { should_not be_able_to_do_anything_to(target).except(allowed) }
          end

          context "as an admin" do
            before { space.add_member!(user, 'Admin') }
            let(:allowed) { [:play, :space_show, :update, :space_edit] }
            it { should_not be_able_to_do_anything_to(target).except(allowed) }
          end
        end
      end
    end

    context "an anonymous user for a recording", :user => "anonymous" do
      context "in a user's room" do
        let(:room) { FactoryGirl.create(:bigbluebutton_room, owner: FactoryGirl.create(:user)) }
        let(:target) { FactoryGirl.create(:bigbluebutton_recording, :room => room) }
        it { should_not be_able_to_do_anything_to(target) }
      end

      context "in a public space" do
        let(:space) { FactoryGirl.create(:space_with_associations, public: true) }
        let(:target) { FactoryGirl.create(:bigbluebutton_recording, :room => space.bigbluebutton_room) }
        let(:allowed) { [:play, :space_show] }
        it { should_not be_able_to_do_anything_to(target).except(allowed) }
      end

      context "in a private space" do
        let(:space) { FactoryGirl.create(:space_with_associations, public: false) }
        let(:target) { FactoryGirl.create(:bigbluebutton_recording, :room => space.bigbluebutton_room) }
        it { should_not be_able_to_do_anything_to(target) }
      end
    end

  end
end
