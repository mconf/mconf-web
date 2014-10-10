# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

# most of the tests here use anonymous controllers, see:
# https://www.relishapp.com/rspec/rspec-rails/docs/controller-specs/anonymous-controller

describe ApplicationController do

  describe "#set_time_zone" do

    # TODO: not sure if tested here or in every action in every controller (sounds bad)
    it "is called before every action"

    it "uses the user timezone if specified"
    it "uses the site timezone if the user's timezone is not specified"
    it "uses UTC if everything fails"
    it "ignores the user if there's no current user"
    it "ignores the user if the user is not an instance of User"
    it "ignores the user if his timezone is not defined"
    it "ignores the user if his timezone is an empty string"
    it "ignores the site if there's no current site"
    it "ignores the site if its timezone is not defined"
    it "ignores the site if its timezone is an empty string"
  end

  describe "#bigbluebutton_role" do
    controller do
      def index
        room = BigbluebuttonRoom.find(params[:room_id])
        @result = bigbluebutton_role(room).freeze
        render :nothing => true
      end
    end

    context "if the owner is not set" do
      let(:room) { FactoryGirl.create(:bigbluebutton_room, :owner => nil) }
      before(:each) { get :index, :room_id => room.id }
      it { assigns(:result).should be_nil }
    end

    context "if the owner is of an invalid type" do
      let(:room) { FactoryGirl.create(:bigbluebutton_room, :owner => FactoryGirl.create(:post)) }
      before(:each) { get :index, :room_id => room.id }
      it { assigns(:result).should be_nil }
    end

    context "for user rooms" do
      context "if the user is disabled" do
        let(:user) { FactoryGirl.create(:user, :disabled => true) }
        let(:room) { FactoryGirl.create(:bigbluebutton_room, :owner => user) }
        before(:each) { get :index, :room_id => room.id }
        it { assigns(:result).should be_nil }
      end

      context "if the user is not found" do
        let(:room) { FactoryGirl.create(:bigbluebutton_room, :owner_id => -1, :owner_type => "User") }
        before(:each) { get :index, :room_id => room.id }
        it { assigns(:result).should be_nil }
      end

      context "if the room is private" do
        let(:user) { FactoryGirl.create(:user) }
        let(:room) { FactoryGirl.create(:bigbluebutton_room, :private => true, :owner => user) }

        context "and the user is the owner" do
          before { controller.stub(:current_user).and_return(user) }
          before(:each) { get :index, :room_id => room.id }
          it { assigns(:result).should eql(:moderator) }
        end

        context "and the user is not the owner" do
          before { controller.stub(:current_user).and_return(FactoryGirl.create(:user)) }
          before(:each) { get :index, :room_id => room.id }
          it { assigns(:result).should eql(:key) }
        end

        context "and there's no user logged" do
          before { controller.stub(:current_user).and_return(nil) }
          before(:each) { get :index, :room_id => room.id }
          it { assigns(:result).should eql(:key) }
        end
      end

      context "if the room is public" do
        let(:user) { FactoryGirl.create(:user) }
        let(:room) { FactoryGirl.create(:bigbluebutton_room, :private => false, :owner => user) }

        context "and the user is the owner" do
          before { controller.stub(:current_user).and_return(user) }
          before(:each) { get :index, :room_id => room.id }
          it { assigns(:result).should eql(:moderator) }
        end

        context "and the user is not the owner" do
          context "and the guest role is enabled" do
            before {
              BigbluebuttonRoom.stub(:guest_support).and_return(true)
              controller.stub(:current_user).and_return(FactoryGirl.create(:user))
            }
            before(:each) { get :index, :room_id => room.id }
            it { assigns(:result).should eql(:guest) }
          end

          context "and the guest role is disabled" do
            before {
              BigbluebuttonRoom.stub(:guest_support).and_return(false)
              controller.stub(:current_user).and_return(FactoryGirl.create(:user))
            }
            before(:each) { get :index, :room_id => room.id }
            it { assigns(:result).should eql(:attendee) }
          end
        end

        context "and there's no user logged" do
          context "and the guest role is enabled" do
            before {
              BigbluebuttonRoom.stub(:guest_support).and_return(true)
              controller.stub(:current_user).and_return(nil)
            }
            before(:each) { get :index, :room_id => room.id }
            it { assigns(:result).should eql(:guest) }
          end

          context "and the guest role is disabled" do
            before {
              BigbluebuttonRoom.stub(:guest_support).and_return(false)
              controller.stub(:current_user).and_return(nil)
            }
            before(:each) { get :index, :room_id => room.id }
            it { assigns(:result).should eql(:attendee) }
          end
        end
      end
    end

    context "for space rooms" do
      context "if the space is disabled" do
        let(:space) { FactoryGirl.create(:space, :disabled => true) }
        let(:room) { FactoryGirl.create(:bigbluebutton_room, :owner => space) }
        before(:each) { get :index, :room_id => room.id }
        it { assigns(:result).should be_nil }
      end

      context "if the space is not found" do
        let(:room) { FactoryGirl.create(:bigbluebutton_room, :owner_id => -1, :owner_type => "Space") }
        before(:each) { get :index, :room_id => room.id }
        it { assigns(:result).should be_nil }
      end

      context "if the room is private" do
        let(:user) { FactoryGirl.create(:user) }
        let(:space) { FactoryGirl.create(:space) }
        let(:room) { FactoryGirl.create(:bigbluebutton_room, :private => true, :owner => space) }

        context "and the user is an admin of the space" do
          before {
            controller.stub(:current_user).and_return(user)
            space.add_member!(user, "Admin")
          }
          before(:each) { get :index, :room_id => room.id }
          it { assigns(:result).should eql(:moderator) }
        end

        context "and the user is a normal member of the space" do
          before {
            controller.stub(:current_user).and_return(user)
            space.add_member!(user, "User")
          }

          context "and there's no meeting running in the room yet" do
            before { BigbluebuttonRoom.any_instance.stub(:is_running?).and_return(false) }
            before(:each) { get :index, :room_id => room.id }
            it { assigns(:result).should eql(:moderator) }
          end

          context "and there's a meeting already running in the room" do
            before { BigbluebuttonRoom.any_instance.stub(:is_running?).and_return(true) }

            context "but the meeting was created by another user" do
              before {
                BigbluebuttonRoom.any_instance.stub(:user_created_meeting?).and_return(false)
              }
              before(:each) { get :index, :room_id => room.id }
              it { assigns(:result).should eql(:attendee) }
            end

            context "and the meeting was created by the user" do
              before {
                BigbluebuttonRoom.any_instance.stub(:user_created_meeting?).and_return(true)
              }
              before(:each) { get :index, :room_id => room.id }
              it { assigns(:result).should eql(:moderator) }
            end
          end
        end

        context "and the user is not a member of the space" do
          before { controller.stub(:current_user).and_return(user) }
          before(:each) { get :index, :room_id => room.id }
          it { assigns(:result).should eql(:key) }
        end

        context "and it's an anonymous user" do
          before { controller.stub(:current_user).and_return(nil) }
          before(:each) { get :index, :room_id => room.id }
          it { assigns(:result).should eql(:key) }
        end
      end

      context "if the room is public" do
        let(:user) { FactoryGirl.create(:user) }
        let(:space) { FactoryGirl.create(:space) }
        let(:room) { FactoryGirl.create(:bigbluebutton_room, :private => false, :owner => space) }

        context "and the user is an admin of the space" do
          before {
            controller.stub(:current_user).and_return(user)
            space.add_member!(user, "Admin")
          }
          before(:each) { get :index, :room_id => room.id }
          it { assigns(:result).should eql(:moderator) }
        end

        context "and the user is a normal member of the space" do
          before {
            controller.stub(:current_user).and_return(user)
            space.add_member!(user, "User")
          }

          context "and there's no meeting running in the room yet" do
            before { BigbluebuttonRoom.any_instance.stub(:is_running?).and_return(false) }
            before(:each) { get :index, :room_id => room.id }
            it { assigns(:result).should eql(:moderator) }
          end

          context "and there's a meeting already running in the room" do
            before { BigbluebuttonRoom.any_instance.stub(:is_running?).and_return(true) }

            context "but the meeting was created by another user" do
              before {
                BigbluebuttonRoom.any_instance.stub(:user_created_meeting?).and_return(false)
              }
              before(:each) { get :index, :room_id => room.id }
              it { assigns(:result).should eql(:attendee) }
            end

            context "and the meeting was created by the user" do
              before {
                BigbluebuttonRoom.any_instance.stub(:user_created_meeting?).and_return(true)
              }
              before(:each) { get :index, :room_id => room.id }
              it { assigns(:result).should eql(:moderator) }
            end
          end
        end

        context "and the user is not a member of the space" do
          context "and the guest role is enabled" do
            before {
              BigbluebuttonRoom.stub(:guest_support).and_return(true)
              controller.stub(:current_user).and_return(user)
            }
            before(:each) { get :index, :room_id => room.id }
            it { assigns(:result).should eql(:guest) }
          end

          context "and the guest role is disabled" do
            before {
              BigbluebuttonRoom.stub(:guest_support).and_return(false)
              controller.stub(:current_user).and_return(user)
            }
            before(:each) { get :index, :room_id => room.id }
            it { assigns(:result).should eql(:attendee) }
          end
        end

        context "and it's an anonymous user" do
          context "and the guest role is enabled" do
            before {
              BigbluebuttonRoom.stub(:guest_support).and_return(true)
              controller.stub(:current_user).and_return(nil)
            }
            before(:each) { get :index, :room_id => room.id }
            it { assigns(:result).should eql(:guest) }
          end

          context "and the guest role is disabled" do
            before {
              BigbluebuttonRoom.stub(:guest_support).and_return(false)
              controller.stub(:current_user).and_return(nil)
            }
            before(:each) { get :index, :room_id => room.id }
            it { assigns(:result).should eql(:attendee) }
          end
        end
      end
    end
  end

  describe "#bigbluebutton_user" do
    it "if current_user is defined and is an instance of User, returns it"
    it "if current_user is not defined returns nil"
    it "if current_user is not an instance of User returns nil"
  end

  describe "#bigbluebutton_can_create?" do
    controller do
      def index
        room = BigbluebuttonRoom.find(params[:room_id])
        @result = bigbluebutton_can_create?(room, params[:role])
        render :nothing => true
      end
    end

    context "if there's no user logged returns false" do
      let(:room) { FactoryGirl.create(:bigbluebutton_room) }
      before(:each) { get :index, :room_id => room.id, :role => :moderator }
      it { assigns(:result).should be_falsey }
    end

    context "if there's a user logged" do
      let(:user) { FactoryGirl.create(:user) }
      let(:room) { FactoryGirl.create(:bigbluebutton_room) }
      before {
        # a custom ability to control what the user can do
        @ability = Object.new
        @ability.extend(CanCan::Ability)
        Abilities.stub(:ability_for).and_return(@ability)
      }

      context "returns can?(:create_meeting)" do
        context "when false" do
          before(:each) { get :index, :room_id => room.id, :role => :moderator }
          it { assigns(:result).should be_falsey }
        end

        context "when true" do
          before { @ability.can :create_meeting, room }
          before(:each) { get :index, :room_id => room.id, :role => :moderator }
          it { assigns(:result).should be_truthy }
        end
      end

    end
  end

  # TODO: We are comparing the results with hashes using string keys, even though
  #   the method returns keys using symbols. Using `assigns()` automatically converts
  #   the symbols to strings, so we can't check it exactly as we should. See:
  #   http://stackoverflow.com/questions/4348195/unwanted-symbol-to-string-conversion-of-hash-key
  describe "#bigbluebutton_create_options" do
    controller do
      def index
        room = BigbluebuttonRoom.find(params[:room_id])
        @result = bigbluebutton_create_options(room).freeze
        render :nothing => true
      end
    end

    context "if there's no user logged returns false" do
      let(:room) { FactoryGirl.create(:bigbluebutton_room) }
      before(:each) { get :index, :room_id => room.id }
      it { assigns(:result).should eql({ record: false }) }
    end

    context "if there's a user logged" do
      let(:user) { FactoryGirl.create(:user) }
      let(:room) { FactoryGirl.create(:bigbluebutton_room) }
      before {
        # a custom ability to control what the user can do
        @ability = Object.new
        @ability.extend(CanCan::Ability)
        Abilities.stub(:ability_for).and_return(@ability)
      }

      context "when the user can record" do
        before { @ability.can :record_meeting, room }

        context "and the site is set to auto set the record flag" do
          before { Site.current.update_attributes(:webconf_auto_record => true) }

          context "and the room is set to record" do
            before { room.update_attributes(record_meeting: true) }
            before(:each) { get :index, :room_id => room.id }
            it { assigns(:result).should eql({ record: true }) }
          end

          context "and the room is not set to record" do
            before { room.update_attributes(record_meeting: false) }
            before(:each) { get :index, :room_id => room.id }
            # uses the user's permission only, ignores that the room is not set to record
            it { assigns(:result).should eql({ record: true }) }
          end
        end

        context "and the site is not set to auto set the record flag" do
          before { Site.current.update_attributes(:webconf_auto_record => false) }

          context "and the room is set to record" do
            before { room.update_attributes(record_meeting: true) }
            before(:each) { get :index, :room_id => room.id }
            it { assigns(:result).should eql({ record: true }) }
          end

          context "and the room is not set to record" do
            before { room.update_attributes(record_meeting: false) }
            before(:each) { get :index, :room_id => room.id }
            it { assigns(:result).should eql({ record: false }) }
          end
        end

      end

      context "when the user cannot record" do
        before { @ability.cannot :record_meeting, room }

        context "and the site is set to auto set the record flag" do
          before { Site.current.update_attributes(:webconf_auto_record => true) }

          context "and the room is set to record" do
            before { room.update_attributes(record_meeting: true) }
            before(:each) { get :index, :room_id => room.id }
            it { assigns(:result).should eql({ record: false }) }
          end

          context "and the room is not set to record" do
            before { room.update_attributes(record_meeting: false) }
            before(:each) { get :index, :room_id => room.id }
            it { assigns(:result).should eql({ record: false }) }
          end
        end

        context "and the site is not set to auto set the record flag" do
          before { Site.current.update_attributes(:webconf_auto_record => false) }

          context "and the room is set to record" do
            before { room.update_attributes(record_meeting: true) }
            before(:each) { get :index, :room_id => room.id }
            it { assigns(:result).should eql({ record: false }) }
          end

          context "and the room is not set to record" do
            before { room.update_attributes(record_meeting: false) }
            before(:each) { get :index, :room_id => room.id }
            it { assigns(:result).should eql({ record: false }) }
          end
        end

      end
    end
  end

end
