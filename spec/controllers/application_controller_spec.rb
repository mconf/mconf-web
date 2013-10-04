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
    context "for user rooms" do
      it "if the user is disabled returns nil"
      context "if the room is private" do
        it "if the user is the owner returns :moderator"
        it "if the user is not the owner returns :password"
        it "if there's no user logged returns :password"
      end
      context "if the room is public" do
        it "if the user is the owner returns :moderator"
        it "if the user is not the owner returns :guest"
        it "if there's no user logged returns :guest"
      end
    end
    context "for space rooms" do
      it "if the space is disabled returns nil"
      context "if the room is private" do
        it "if the user is a member of the space returns :moderator"
        it "if the user is not a member of the space :password"
      end
      context "if the room is public" do
        it "if the user is a member of the space returns :moderator"
        it "if the user is not a member of the space :guest"
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
        room = BigbluebuttonRoom.find_by_id(params[:room_id])
        @result = bigbluebutton_can_create?(room, params[:role])
        render :nothing => true
      end
    end

    context "if there's no user logged returns false" do
      let(:room) { FactoryGirl.create(:bigbluebutton_room) }
      before(:each) { get :index, :room_id => room.id, :role => :moderator }
      it { assigns(:result).should be_false }
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
          it { assigns(:result).should be_false }
        end

        context "when true" do
          before { @ability.can :create_meeting, room }
          before(:each) { get :index, :room_id => room.id, :role => :moderator }
          it { assigns(:result).should be_true }
        end
      end

      context "when the flag 'auto record flag' is set in the site" do
        before { Site.current.update_attributes(:webconf_auto_record => true) }

        context "if the user cannot record, automatically sets the record flag to false" do
          before {
            room.update_attributes(:record => true)
            @ability.can :create_meeting, room
            BigbluebuttonRoom.stub(:find_by_id).and_return(room)
          }
          before(:each) { get :index, :room_id => room.id, :role => :moderator }
          it { room.record.should be_false }
        end

        context "if the user can record, automatically sets the record flag to true" do
          before {
            room.update_attributes(:record => false)
            @ability.can :create_meeting, room
            @ability.can :record_meeting, room
            BigbluebuttonRoom.stub(:find_by_id).and_return(room)
          }
          before(:each) { get :index, :room_id => room.id, :role => :moderator }
          it { room.record.should be_true }
        end
      end

      context "when the flag 'auto record flag' is not set in the site" do
        before { Site.current.update_attributes(:webconf_auto_record => false) }

        context "if the user cannot record, sets the record flag to false" do
          before {
            room.update_attributes(:record => true)
            @ability.can :create_meeting, room
            BigbluebuttonRoom.stub(:find_by_id).and_return(room)
          }
          before(:each) { get :index, :room_id => room.id, :role => :moderator }
          it { room.record.should be_false }
        end

        context "if the user can record, leaves the record flag as it was before" do
          [false, true].each do |value|
            context "when it was #{value}" do
              before {
                room.update_attributes(:record => value) # initial value
                @ability.can :create_meeting, room
                @ability.can :record_meeting, room
                BigbluebuttonRoom.stub(:find_by_id).and_return(room)
              }
              before(:each) {
                room.should_not_receive(:update_attribute).with(:record, false)
                get :index, :room_id => room.id, :role => :moderator
              }
              it { room.record.should be(value) }
            end
          end
        end
      end

    end
  end

end
