# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe BigbluebuttonRoom do

  describe "from initializers/bigbluebutton_rails" do
    it("should have a method .guest_support") {
      BigbluebuttonRoom.should respond_to(:guest_support)
    }

    it "overrides #join_url with guest support"

    describe "#user_created_meeting?" do
      it "false if there's no current meeting running in the room"
      it "false if it was another user that created the current meeting running in the room"
      it "true if the current meeting running in the room was created by the user informed"
    end
  end

  # This is a model from BigbluebuttonRails, but we have permissions set in cancan for it,
  # so we test them here.
  describe "abilities", :abilities => true do
    set_custom_ability_actions([ :end, :join_options, :create_meeting, :fetch_recordings,
                                 :invite, :invite_userid, :running, :join, :join_mobile,
                                 :record_meeting, :invitation, :send_invitation ])

    subject { ability }
    let(:user) { nil }
    let(:ability) { Abilities.ability_for(user) }

    context "a superuser", :user => "superuser" do
      let(:user) { FactoryGirl.create(:superuser) }

      context "in his own room" do
        let(:target) { user.bigbluebutton_room }
        it { should be_able_to(:manage, target) }
      end

      context "in another user's room" do
        let(:another_user) { FactoryGirl.create(:user) }
        let(:target) { another_user.bigbluebutton_room }
        it { should be_able_to(:manage, target) }
      end

      context "in a public space" do
        let(:space) { FactoryGirl.create(:space, :public => true) }
        let(:target) { space.bigbluebutton_room }

        context "he doesn't belong to" do
          it { should be_able_to(:manage, target) }
        end

        context "he belongs to" do
          before { space.add_member!(user) }
          it { should be_able_to(:manage, target) }
        end
      end

      context "in a private space" do
        let(:space) { FactoryGirl.create(:space, :public => false) }
        let(:target) { space.bigbluebutton_room }

        context "he doesn't belong to" do
          it { should be_able_to(:manage, target) }
        end

        context "he belongs to" do
          before { space.add_member!(user) }
          it { should be_able_to(:manage, target) }
        end
      end

      context "for a room without owner" do
        let(:target) { FactoryGirl.create(:bigbluebutton_room, :owner => nil) }
        it { should be_able_to(:manage, target) }
      end

      context "for a room with an invalid owner_type" do
        let(:target) { FactoryGirl.create(:bigbluebutton_room, :owner_type => "invalid type") }
        it { should be_able_to(:manage, target) }
      end
    end

    context "a normal user", :user => "normal" do
      let(:user) { FactoryGirl.create(:user) }

      context "in his own room" do
        let(:target) { user.bigbluebutton_room }
        let(:allowed) { [:end, :join_options, :create_meeting, :fetch_recordings,
                         :invite, :invite_userid, :running, :join,
                         :join_mobile, :update, :invitation, :send_invitation] }
        it { should_not be_able_to_do_anything_to(target).except(allowed) }

        context "with permission to record" do
          before { user.update_attributes(:can_record => true) }
          it { should be_able_to(:record_meeting, target) }
        end
      end

      context "in another user's room" do
        let(:another_user) { FactoryGirl.create(:user) }
        let(:target) { another_user.bigbluebutton_room }
        let(:allowed) { [:invite, :invite_userid, :running, :join, :join_mobile] }
        it { should_not be_able_to_do_anything_to(target).except(allowed) }

        context "with permission to record" do
          before { user.update_attributes(:can_record => true) }
          it { should_not be_able_to(:record_meeting, target) }
        end
      end

      context "in a public space" do
        let(:space) { FactoryGirl.create(:space, :public => true) }
        let(:target) { space.bigbluebutton_room }

        context "he doesn't belong to" do
          let(:allowed) { [:invite, :invite_userid, :running, :join, :join_mobile] }
          it { should_not be_able_to_do_anything_to(target).except(allowed) }

          context "with permission to record" do
            before { user.update_attributes(:can_record => true) }
            it { should_not be_able_to(:record_meeting, target) }
          end
        end

        context "he belongs to" do
          before { space.add_member!(user) }
          let(:allowed) { [:join_options, :create_meeting, :fetch_recordings,
                           :invite, :invite_userid, :running, :join, :join_mobile,
                           :invitation, :send_invitation] }
          it { should_not be_able_to_do_anything_to(target).except(allowed) }

          context "and has opened the room" do
            let(:meeting) { FactoryGirl.create(:bigbluebutton_meeting, :creator_id => user.id, :room => space.bigbluebutton_room) }

            before :each do
              BigbluebuttonRoom.any_instance.stub(:fetch_is_running?).and_return()
              BigbluebuttonRoom.any_instance.stub(:is_running?).and_return(true)
              BigbluebuttonRoom.any_instance.stub(:fetch_meeting_info).and_return()
              BigbluebuttonRoom.any_instance.stub(:user_creator).and_return(:id => user.id, :name => user._full_name)
              BigbluebuttonRoom.any_instance.stub(:get_current_meeting).and_return(meeting)
            end
            it { should be_able_to(:end, target) }
          end

          context "with permission to record" do
            before { user.update_attributes(:can_record => true) }
            it { should be_able_to(:record_meeting, target) }
          end
        end

        context "he belongs to and are a admin" do
          before { space.add_member!(user, "Admin") }
          let(:allowed) { [:end, :join_options, :create_meeting, :fetch_recordings,
                           :invite, :invite_userid, :running, :join, :join_mobile,
                           :invitation, :send_invitation] }
          it { should_not be_able_to_do_anything_to(target).except(allowed) }
        end
      end

      context "in a private space" do
        let(:space) { FactoryGirl.create(:space, :public => false) }
        let(:target) { space.bigbluebutton_room }

        context "he doesn't belong to" do
          let(:allowed) { [:invite, :invite_userid, :running, :join, :join_mobile] }
          it { should_not be_able_to_do_anything_to(target).except(allowed) }

          context "with permission to record" do
            before { user.update_attributes(:can_record => true) }
            it { should_not be_able_to(:record_meeting, target) }
          end
        end

        context "he belongs to" do
          before { space.add_member!(user) }
          let(:allowed) { [:join_options, :create_meeting, :fetch_recordings,
                           :invite, :invite_userid, :running, :join, :join_mobile,
                           :invitation, :send_invitation] }
          it { should_not be_able_to_do_anything_to(target).except(allowed) }

          context "and has opened the room" do
            let(:meeting) { FactoryGirl.create(:bigbluebutton_meeting, :creator_id => user.id, :room => space.bigbluebutton_room) }

            before :each do
              BigbluebuttonRoom.any_instance.stub(:fetch_is_running?).and_return()
              BigbluebuttonRoom.any_instance.stub(:is_running?).and_return(true)
              BigbluebuttonRoom.any_instance.stub(:fetch_meeting_info).and_return()
              BigbluebuttonRoom.any_instance.stub(:user_creator).and_return(:id => user.id, :name => user._full_name)
              BigbluebuttonRoom.any_instance.stub(:get_current_meeting).and_return(meeting)
            end
            it { should be_able_to(:end, target) }
          end

          context "with permission to record" do
            before { user.update_attributes(:can_record => true) }
            it { should be_able_to(:record_meeting, target) }
          end
        end

        context "he belongs to and are a admin" do
          before { space.add_member!(user, "Admin") }
          let(:allowed) { [:end, :join_options, :create_meeting, :fetch_recordings,
                           :invite, :invite_userid, :running, :join, :join_mobile,
                           :invitation, :send_invitation] }
          it { should_not be_able_to_do_anything_to(target).except(allowed) }
        end
      end

      context "for a room without owner" do
        let(:target) { FactoryGirl.create(:bigbluebutton_room, :owner => nil) }
        let(:allowed) { [:invite, :invite_userid, :running, :join, :join_mobile] }
        before :each do
          BigbluebuttonRoom.any_instance.stub(:fetch_is_running?).and_return()
        end
        it { should_not be_able_to_do_anything_to(target).except(allowed) }
      end

      context "for a room with an invalid owner_type" do
        let(:target) { FactoryGirl.create(:bigbluebutton_room, :owner_type => "invalid type") }
        let(:allowed) { [:invite, :invite_userid, :running, :join, :join_mobile] }
        before :each do
          BigbluebuttonRoom.any_instance.stub(:fetch_is_running?).and_return()
        end
        it { should_not be_able_to_do_anything_to(target).except(allowed) }
      end
    end

    context "an anonymous user", :user => "anonymous" do
      context "in a user's room" do
        let(:target) { FactoryGirl.create(:user).bigbluebutton_room }
        let(:allowed) { [:invite, :invite_userid, :join, :join_mobile, :running] }
        it { should_not be_able_to_do_anything_to(target).except(allowed) }
      end

      context "in a public space" do
        let(:space) { FactoryGirl.create(:space, :public => true) }
        let(:target) { space.bigbluebutton_room }
        let(:allowed) { [:invite, :invite_userid, :join, :join_mobile, :running] }
        it { should_not be_able_to_do_anything_to(target).except(allowed) }
      end

      context "in a private space" do
        let(:space) { FactoryGirl.create(:space, :public => false) }
        let(:target) { space.bigbluebutton_room }
        let(:allowed) { [:invite, :invite_userid, :join, :join_mobile, :running] }
        it { should_not be_able_to_do_anything_to(target).except(allowed) }
      end

      context "for a room without owner" do
        let(:target) { FactoryGirl.create(:bigbluebutton_room, :owner => nil) }
        it { should_not be_able_to_do_anything_to(target) }
      end

      context "for a room with an invalid owner_type" do
        let(:target) { FactoryGirl.create(:bigbluebutton_room, :owner_type => "invalid type") }
        it { should_not be_able_to_do_anything_to(target) }
      end
    end

  end
end
