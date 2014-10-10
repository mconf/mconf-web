# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe CustomBigbluebuttonRoomsController do
  render_views

  describe "#invite_userid" do
    context "template and layout" do
      let(:room) { FactoryGirl.create(:bigbluebutton_room, :owner => FactoryGirl.create(:user)) }
      let(:hash) { { :server_id => room.server.to_param, :id => room.to_param } }

      context "template" do
        before(:each) { get :invite_userid, hash }
        it { should render_template(:invite_userid) }
        it { should render_with_layout("no_sidebar") }
      end

      context "redirects to #invite" do
        let(:user) { FactoryGirl.create(:user) }

        it "when there is a user logged" do
          login_as(user)
          get :invite_userid, hash
          response.should redirect_to(invite_bigbluebutton_room_path(room))
        end

        it "when the user name is specified" do
          get :invite_userid, hash.merge(:user => { :name => "My User" })
          response.should redirect_to(invite_bigbluebutton_room_path(room, :user => { :name => "My User" }))
        end
      end
    end

    it "loads and authorizes the room into @room"
  end

  describe "#invite" do
    context "template and layout" do
      let(:room) { FactoryGirl.create(:bigbluebutton_room, :owner => FactoryGirl.create(:user)) }
      let(:hash) { { :server_id => room.server.to_param, :id => room.to_param } }

      context "template" do
        let(:hash) { { :server_id => room.server.to_param, :id => room.to_param } }
        before { controller.should_receive(:bigbluebutton_role) { :key } }
        before(:each) {
          login_as(FactoryGirl.create(:superuser))
          get :invite, hash
        }
        it { should render_template(:invite) }
        it { should render_with_layout("no_sidebar") }
      end

      context "redirects to #invite_userid" do
        it "when the user name is not specified" do
          get :invite, hash
          response.should redirect_to(join_webconf_path(room))
        end

        it "when the user name is empty" do
          get :invite, hash.merge(:user => { :name => {} })
          response.should redirect_to(join_webconf_path(room))
        end

        it "when the user name is blank" do
          get :invite, hash.merge(:user => { :name => "" })
          response.should redirect_to(join_webconf_path(room))
        end
      end
    end

    it "loads and authorizes the room into @room"
  end

  describe "#index" do
    context "template and layout" do
      before(:each) { login_as(FactoryGirl.create(:superuser)) }
      before(:each) { get :index }
      it { should render_template(:index) }
      it { should render_with_layout("application") }
    end

    it "loads the rooms into @rooms"
  end

  describe "#show" do
    context "template and layout" do
      let(:room) { FactoryGirl.create(:bigbluebutton_room) }
      before(:each) { login_as(FactoryGirl.create(:superuser)) }
      before(:each) { get :show, :id => room.to_param }
      it { should render_template(:show) }
      it { should render_with_layout("application") }
    end

    it "loads and authorizes the room into @room"
  end

  describe "#new" do
    context "template and layout" do
      before(:each) { login_as(FactoryGirl.create(:superuser)) }
      before(:each) { get :new }
      it { should render_template(:new) }
      it { should render_with_layout("application") }
    end

    it "loads and authorizes the room into @room"
  end

  describe "#edit" do
    context "template and layout" do
      let(:room) { FactoryGirl.create(:bigbluebutton_room) }
      before(:each) { login_as(FactoryGirl.create(:superuser)) }
      before(:each) { get :edit, :id => room.to_param }
      it { should render_template(:edit) }
      it { should render_with_layout("application") }
    end

    it "loads and authorizes the room into @room"
  end

  describe "#join_mobile" do
    let(:room) { FactoryGirl.create(:bigbluebutton_room) }
    before(:each) { login_as(FactoryGirl.create(:superuser)) }

    context "template and layout for html requests" do
      before(:each) { get :join_mobile, :id => room.to_param }
      it { should render_template(:join_mobile) }
      it { should render_with_layout("mobile") }
    end

    it "loads and authorizes the room into @room"
  end

  describe "#create" do
    context "template and layout" do
      # renders a view only on error on save
      let(:attrs) { FactoryGirl.attributes_for(:bigbluebutton_room) }
      before(:each) { login_as(FactoryGirl.create(:superuser)) }
      before :each do
        attrs[:name] = nil # invalidate it
        post :create, :bigbluebutton_room => attrs
      end
      it { should render_template(:new) }
      it { should render_with_layout("application") }
    end

    it "loads and authorizes the room into @room"
  end

  describe "#update" do
    let(:room) { FactoryGirl.create(:bigbluebutton_room) }

    context "template and layout" do
      # renders a view only on error on save
      let(:attrs) { FactoryGirl.attributes_for(:bigbluebutton_room) }
      before(:each) { login_as(FactoryGirl.create(:superuser)) }
      before(:each) {
        attrs[:name] = nil # invalidate it
        put :update, :id => room.to_param, :bigbluebutton_room => attrs
      }
      it { should render_template(:edit) }
      it { should render_with_layout("application") }
    end

    # This is an adapted copy of the same test done for this controller action in BigbluebuttonRails
    # we just check that the method 'permit' is being called with the correct parameters and assume
    # it does what it should.
    context "params handling" do
      let(:attrs) { FactoryGirl.attributes_for(:bigbluebutton_room) }
      let(:params) { { :controller => 'CustomBigbluebuttonRoomsController', :action => :update, :bigbluebutton_room => attrs } }

      context "for a superuser" do
        let(:user) { FactoryGirl.create(:superuser) }
        before(:each) { login_as(user) }

        let(:allowed_params) {
          [ :name, :server_id, :meetingid, :attendee_key, :moderator_key, :welcome_msg,
            :private, :logout_url, :dial_number, :voice_bridge, :max_participants, :owner_id,
            :owner_type, :external, :param, :record_meeting, :duration, :default_layout, :presenter_share_only,
            :auto_start_video, :auto_start_audio, :metadata_attributes => [ :id, :name, :content, :_destroy, :owner_id ] ]
        }
        it {
          BigbluebuttonRoom.stub(:find_by_param).and_return(room)
          room.stub(:update_attributes).and_return(true)
          attrs.stub(:permit).and_return(attrs)
          controller.stub(:params).and_return(params)

          # BigbluebuttonRoom.any_instance.stub(:fetch_is_running?) { true }
          # BigbluebuttonRoom.any_instance.stub(:fetch_meeting_info) { Hash.new }

          put :update, :id => room.to_param, :bigbluebutton_room => attrs
          attrs.should have_received(:permit).with(*allowed_params)
        }
      end

      context "for a normal user" do
        let(:user) { FactoryGirl.create(:user) }
        let(:room) { user.bigbluebutton_room }
        before(:each) { login_as(user) }

        let(:allowed_params) {
          [ :attendee_key, :moderator_key, :private, :record_meeting, :default_layout, :presenter_share_only,
            :auto_start_video, :auto_start_audio, :welcome_msg, :metadata_attributes => [ :id, :name, :content, :_destroy, :owner_id ] ]
        }
        it {
          BigbluebuttonRoom.stub(:find_by_param).and_return(room)
          room.stub(:update_attributes).and_return(true)
          attrs.stub(:permit).and_return(attrs)
          controller.stub(:params).and_return(params)

          put :update, :id => room.to_param, :bigbluebutton_room => attrs
          attrs.should have_received(:permit).with(*allowed_params)
        }
      end
    end

    it "loads and authorizes the room into @room"
  end

  describe "#running" do
    context "template and layout" do
      # renders json only
      let(:room) { FactoryGirl.create(:bigbluebutton_room) }
      before(:each) { login_as(FactoryGirl.create(:superuser)) }
      before(:each) { get :running, :id => room.to_param }
      it { should respond_with(:success) }
      it { should_not render_with_layout() }
    end

    it "loads and authorizes the room into @room"
  end

  # TODO: this view is not in the application yet, only in the gem
  # describe "#recordings" do
  #   context "template and layout" do
  #     let(:room) { FactoryGirl.create(:bigbluebutton_room) }
  #     before(:each) { login_as(FactoryGirl.create(:superuser)) }
  #     before(:each) { get :recordings, :id => room.to_param }
  #     it { should render_template(:recordings) }
  #     it { should render_with_layout("application") }
  #   end
  # end

  describe "#join_options" do
    let(:user) { FactoryGirl.create(:user) }
    let(:room) { user.bigbluebutton_room }
    before(:each) { login_as(user) }

    before {
      # a custom ability to control what the user can do
      @ability = Object.new
      @ability.extend(CanCan::Ability)
      @ability.can :join_options, room
      Abilities.stub(:ability_for).and_return(@ability)
      BigbluebuttonRoom.stub(:fetch_is_running?) { true }
      BigbluebuttonRoom.stub(:fetch_meeting_info) { Hash.new }
    }

    context "if the user can't record meetings in this room" do
      before(:each) { get :join_options, :id => room.to_param }
      it { should redirect_to(join_bigbluebutton_room_path(room)) }
    end

    context "if the user can record meetings in this room" do
      before(:each) { @ability.can :record_meeting, room }

      context "if the flag 'auto record flag' is set in the site" do
        before { Site.current.update_attributes(:webconf_auto_record => true) }
        before(:each) { get :join_options, :id => room.to_param }
        it { should redirect_to(join_bigbluebutton_room_path(room)) }
      end

      context "if the flag 'auto record flag' is not set in the site" do
        before { Site.current.update_attributes(:webconf_auto_record => false) }

        context "template and layout for html requests" do
          before(:each) { get :join_options, :id => room.to_param }
          it { should render_template(:join_options) }
          it { should render_with_layout("application") }
        end

        context "template and layout for xhr requests" do
          before(:each) { xhr :get, :join_options, :id => room.to_param }
          it { should render_template(:join_options) }
          it { should_not render_with_layout() }
        end
      end
    end

    it "loads and authorizes the room into @room"
  end

  describe "#join" do

    for method in [:get, :post]
      context "via #{method}" do

        context "via GET" do
          context "fetches information about the room when calling #join" do
            let(:user) { FactoryGirl.create(:user) }
            let(:room) { user.bigbluebutton_room }
            before {
              login_as(user)
              BigbluebuttonRoom.stub(:find_by_param) { room }
            }

            context "when a meeting is running" do
              before {
                room.stub(:is_running?) { true }
                room.should_receive(:fetch_is_running?).at_least(:once) { true }
                room.should_receive(:fetch_meeting_info)
              }
              it { send(method, :join, :id => room.to_param) }
            end

            context "when no meeting is running" do
              before {
                room.stub(:is_running?) { false }
                room.should_receive(:fetch_is_running?).at_least(:once) { false }
                room.should_not_receive(:fetch_meeting_info)
              }
              it { send(method, :join, :id => room.to_param) }
            end
          end

          # important to check this because join runs methods such as ApplicationController.bigbluebutton_role
          # that need the information fetch in the before filters
          context "#join is called with the same @room that we fetched information from" do
            let(:user) { FactoryGirl.create(:user) }
            let(:room) { user.bigbluebutton_room }
            before {
              login_as(user)
              BigbluebuttonRoom.should_receive(:find_by_param).once { room }
              controller.should_receive(:bigbluebutton_role).with(room) { :moderator }
              room.stub(:is_running?) { true }
              room.should_receive(:fetch_is_running?).at_least(:once) { true }
              room.should_receive(:fetch_meeting_info).once {
                room.running = true
                room.participant_count = 4
              }
            }
            before(:each) { send(method, :join, :id => room.to_param) }
            it { should assign_to(:room).with(room) }
            it { assigns(:room).running.should be true }
            it { assigns(:room).participant_count.should be 4 }
          end

          context "when submitting the moderator password" do
            let(:user) { FactoryGirl.create(:user) }
            let(:room) { user.bigbluebutton_room }
            let(:server) { room.server }

            context "creates the room if the current user is the owner" do
              before :each do
                login_as(user)
                request.env["HTTP_REFERER"] = "/any"
                BigbluebuttonRoom.stub(:find_by_param) { room }

                # to guide the behavior of #join, copied from the tests in BigbluebuttonRails
                room.should_receive(:fetch_is_running?).at_least(:once).and_return(false)
                room.should_receive(:create_meeting).with(user, anything, anything)
                room.should_receive(:fetch_new_token)
                room.should_receive(:join_url).and_return("http://test.com/attendee/join")
              end
              before(:each) { send(method, :join, :id => room.to_param, :user => { :key => room.moderator_key, :name => "Any Name" }) }
              it { should respond_with(:redirect) }
              it { should redirect_to("http://test.com/attendee/join") }
            end

            # to make sure a user can't create a meeting in a room simply by submitting the
            # moderator password; he needs permissions on the room as well
            context "doesn't create the room if the current user is not the owner" do
              before :each do
                another_user = FactoryGirl.create(:user)
                login_as(another_user)
                request.env["HTTP_REFERER"] = "/any"
                BigbluebuttonRoom.stub(:find_by_param) { room }
                BigbluebuttonRoom.any_instance.stub(:fetch_is_running?) { false }

                # to guide the behavior of #join, copied from the tests in BigbluebuttonRails
                server.api.stub(:is_meeting_running?) { false }
              end
              before(:each) { send(method, :join, :id => room.to_param, :user => { :key => room.moderator_key, :name => "Any Name" }) }
              it { should respond_with(:redirect) }
              it { should redirect_to("/any") }
              it { should set_the_flash.to(I18n.t('bigbluebutton_rails.rooms.errors.join.cannot_create')) }
            end
          end

        end
      end

    end
  end

  describe "#end" do
    before {
      request.env["HTTP_REFERER"] = "/any"
    }

    context "fetches information about the room when calling #end" do
      let(:user) { FactoryGirl.create(:user) }
      let(:room) { user.bigbluebutton_room }
      before {
        login_as(user)
        BigbluebuttonRoom.stub(:find_by_param) { room }
      }

      context "when a meeting is running" do
        before {
          room.stub(:is_running?) { true }
          room.should_receive(:fetch_is_running?).at_least(:once) { true }
          room.should_receive(:fetch_meeting_info)
        }
        it { get :end, :id => room.to_param }
      end

      context "when no meeting is running" do
        before {
          room.stub(:is_running?) { false }
          room.should_receive(:fetch_is_running?).at_least(:once) { false }
          room.should_not_receive(:fetch_meeting_info)
        }
        it { get :end, :id => room.to_param }
      end
    end

    # important to check this because end runs methods that need the information fetch in the
    # before filters
    context "#end is called with the same @room that we fetched information from" do
      let(:user) { FactoryGirl.create(:user) }
      let(:room) { user.bigbluebutton_room }
      before {
        login_as(user)
        BigbluebuttonRoom.should_receive(:find_by_param).once { room }
        room.stub(:is_running?) { true }
        room.should_receive(:fetch_is_running?).at_least(:once) { true }
        room.should_receive(:fetch_meeting_info).once {
          room.running = true
          room.participant_count = 4
        }
      }
      before(:each) { get :end, :id => room.to_param }
      it { should assign_to(:room).with(room) }
      it { assigns(:room).running.should be true }
      it { assigns(:room).participant_count.should be 4 }
    end
  end

  describe "abilities", :abilities => true do
    render_views(false)

    before {
      # a few things (specially for :join) run in before filters, so we have to make sure the
      # before filters will run successfully and the target action will be called
      BigbluebuttonRoom.any_instance.stub(:fetch_is_running?).and_return(true)
    }

    context "for a superuser", :user => "superuser" do
      let(:user) { FactoryGirl.create(:superuser) }
      let(:hash) { { :id => room.to_param } }
      let(:hash_with_user) { hash.merge({ :user => { :name => "User Name", :key => room.attendee_key } }) }

      before(:each) {
        login_as(user)
        BigbluebuttonRoom.any_instance.stub(:fetch_is_running?) { true }
        BigbluebuttonRoom.any_instance.stub(:fetch_meeting_info) { Hash.new }
      }

      it { should allow_access_to(:index) }
      it { should allow_access_to(:new) }
      it { should allow_access_to(:create).via(:post) }

      # the permissions are always the same, doesn't matter the type of room, so
      # we have them all in this common method
      shared_examples_for "a superuser accessing a webconf room in CustomBigbluebuttonRoomsController" do
        it { should allow_access_to(:show, hash) }
        it { should allow_access_to(:edit, hash) }
        it { should allow_access_to(:update, hash).via(:put) }
        it { should allow_access_to(:destroy, hash).via(:delete) }
        it { should allow_access_to(:join, hash_with_user) }
        it { should allow_access_to(:join, hash_with_user).via(:post) }
        it { should allow_access_to(:invite, hash) }
        it { should allow_access_to(:invite_userid, hash).redirecting_to(invite_bigbluebutton_room_path(room)) }
        it { should allow_access_to(:end, hash) }
        it { should allow_access_to(:join_mobile, hash) }
        it { should allow_access_to(:running, hash) }
        it { should allow_access_to(:join_options, hash) }
        it { should allow_access_to(:fetch_recordings, hash) }
        it { should allow_access_to(:invitation, hash) }
        it { should allow_access_to(:send_invitation, hash).via(:post) }
      end

      context "in his room" do
        let(:room) { user.bigbluebutton_room }
        it_should_behave_like "a superuser accessing a webconf room in CustomBigbluebuttonRoomsController"
      end

      context "in another user's room" do
        let(:room) { FactoryGirl.create(:superuser).bigbluebutton_room }
        it_should_behave_like "a superuser accessing a webconf room in CustomBigbluebuttonRoomsController"
      end

      context "in the room of public space" do
        let(:space) { FactoryGirl.create(:space, :public => true) }
        let(:room) { space.bigbluebutton_room }

        context "he is a member of" do
          before { space.add_member!(user) }
          it_should_behave_like "a superuser accessing a webconf room in CustomBigbluebuttonRoomsController"
        end

        context "he is not a member of" do
          it_should_behave_like "a superuser accessing a webconf room in CustomBigbluebuttonRoomsController"
        end
      end

      context "in the room of private space" do
        let(:space) { FactoryGirl.create(:space, :public => false) }
        let(:room) { space.bigbluebutton_room }

        context "he is a member of" do
          before { space.add_member!(user) }
          it_should_behave_like "a superuser accessing a webconf room in CustomBigbluebuttonRoomsController"
        end

        context "he is not a member of" do
          it_should_behave_like "a superuser accessing a webconf room in CustomBigbluebuttonRoomsController"
        end
      end
    end

    context "for a normal user", :user => "normal" do
      let(:user) { FactoryGirl.create(:user) }
      let(:hash) { { :id => room.to_param } }
      let(:hash_with_user) { hash.merge({ :user => { :name => "User Name", :key => room.attendee_key } }) }

      before(:each) {
        login_as(user)
        BigbluebuttonRoom.any_instance.stub(:fetch_is_running?) { true }
        BigbluebuttonRoom.any_instance.stub(:fetch_meeting_info) { Hash.new }
      }

      it { should_not allow_access_to(:index) }
      it { should_not allow_access_to(:new) }
      it { should_not allow_access_to(:create).via(:post) }

      context "in his room" do
        let(:room) { user.bigbluebutton_room }
        it { should_not allow_access_to(:show, hash) }
        it { should_not allow_access_to(:edit, hash) }
        it { should allow_access_to(:update, hash).via(:put) }
        it { should_not allow_access_to(:destroy, hash).via(:delete) }
        it { should allow_access_to(:join, hash_with_user) }
        it { should allow_access_to(:join, hash_with_user).via(:post) }
        it { should allow_access_to(:invite, hash) }
        it { should allow_access_to(:invite_userid, hash).redirecting_to(invite_bigbluebutton_room_path(room)) }
        it { should allow_access_to(:end, hash) }
        it { should allow_access_to(:join_mobile, hash) }
        it { should allow_access_to(:running, hash) }
        it { should allow_access_to(:join_options, hash) }
        it { should allow_access_to(:fetch_recordings, hash) }
        it { should allow_access_to(:invitation, hash) }
        it { should allow_access_to(:send_invitation, hash).via(:post) }
      end

      context "in another user's room" do
        let(:room) { FactoryGirl.create(:superuser).bigbluebutton_room }
        it { should_not allow_access_to(:show, hash) }
        it { should_not allow_access_to(:edit, hash) }
        it { should_not allow_access_to(:update, hash).via(:put) }
        it { should_not allow_access_to(:destroy, hash).via(:delete) }
        it { should allow_access_to(:join, hash_with_user) }
        it { should allow_access_to(:join, hash_with_user).via(:post) }
        it { should allow_access_to(:invite, hash) }
        it { should allow_access_to(:invite_userid, hash).redirecting_to(invite_bigbluebutton_room_path(room)) }
        it { should_not allow_access_to(:end, hash) }
        it { should allow_access_to(:join_mobile, hash) }
        it { should allow_access_to(:running, hash) }
        it { should_not allow_access_to(:join_options, hash) }
        it { should_not allow_access_to(:fetch_recordings, hash) }
        it { should_not allow_access_to(:invitation, hash) }
        it { should_not allow_access_to(:send_invitation, hash).via(:post) }
      end

      context "in the room of public space" do
        let(:space) { FactoryGirl.create(:space, :public => true) }
        let(:room) { space.bigbluebutton_room }

        context "he is a member of" do
          before { space.add_member!(user, "User") }
          it { should_not allow_access_to(:show, hash) }
          it { should_not allow_access_to(:edit, hash) }
          it { should_not allow_access_to(:update, hash).via(:put) }
          it { should_not allow_access_to(:destroy, hash).via(:delete) }
          it { should allow_access_to(:join, hash_with_user) }
          it { should allow_access_to(:join, hash_with_user).via(:post) }
          it { should allow_access_to(:invite, hash) }
          it { should allow_access_to(:invite_userid, hash).redirecting_to(invite_bigbluebutton_room_path(room)) }
          it { should_not allow_access_to(:end, hash) }
          it { should allow_access_to(:join_mobile, hash) }
          it { should allow_access_to(:running, hash) }
          it { should allow_access_to(:join_options, hash) }
          it { should allow_access_to(:fetch_recordings, hash) }
          it { should allow_access_to(:invitation, hash) }
          it { should allow_access_to(:send_invitation, hash).via(:post) }

          context "and he opened the room" do
            before :each do
              meeting = FactoryGirl.create(:bigbluebutton_meeting, :room => room, :running => true,
                                           :creator_id => user.id, :creator_name => user.full_name)
              BigbluebuttonRoom.any_instance.stub(:start_time).and_return(meeting.start_time.utc)
            end
            it { should allow_access_to(:end, hash) }
          end
        end

        context "he is a admin of" do
          before { space.add_member!(user, "Admin") }
          it { should_not allow_access_to(:show, hash) }
          it { should_not allow_access_to(:edit, hash) }
          it { should_not allow_access_to(:update, hash).via(:put) }
          it { should_not allow_access_to(:destroy, hash).via(:delete) }
          it { should allow_access_to(:join, hash_with_user) }
          it { should allow_access_to(:join, hash_with_user).via(:post) }
          it { should allow_access_to(:invite, hash) }
          it { should allow_access_to(:invite_userid, hash).redirecting_to(invite_bigbluebutton_room_path(room)) }
          it { should allow_access_to(:end, hash) }
          it { should allow_access_to(:join_mobile, hash) }
          it { should allow_access_to(:running, hash) }
          it { should allow_access_to(:join_options, hash) }
          it { should allow_access_to(:fetch_recordings, hash) }
          it { should allow_access_to(:invitation, hash) }
          it { should allow_access_to(:send_invitation, hash).via(:post) }
        end

        context "he is not a member of" do
          it { should_not allow_access_to(:show, hash) }
          it { should_not allow_access_to(:edit, hash) }
          it { should_not allow_access_to(:update, hash).via(:put) }
          it { should_not allow_access_to(:destroy, hash).via(:delete) }
          it { should allow_access_to(:join, hash_with_user) }
          it { should allow_access_to(:join, hash_with_user).via(:post) }
          it { should allow_access_to(:invite, hash) }
          it { should allow_access_to(:invite_userid, hash).redirecting_to(invite_bigbluebutton_room_path(room)) }
          it { should_not allow_access_to(:end, hash) }
          it { should allow_access_to(:join_mobile, hash) }
          it { should allow_access_to(:running, hash) }
          it { should_not allow_access_to(:join_options, hash) }
          it { should_not allow_access_to(:fetch_recordings, hash) }
          it { should_not allow_access_to(:invitation, hash) }
          it { should_not allow_access_to(:send_invitation, hash).via(:post) }
        end
      end

      context "in the room of private space" do
        let(:space) { FactoryGirl.create(:space, :public => false) }
        let(:room) { space.bigbluebutton_room }

        context "he is a member of" do
          before { space.add_member!(user, "User") }
          it { should_not allow_access_to(:show, hash) }
          it { should_not allow_access_to(:edit, hash) }
          it { should_not allow_access_to(:update, hash).via(:put) }
          it { should_not allow_access_to(:destroy, hash).via(:delete) }
          it { should allow_access_to(:join, hash_with_user) }
          it { should allow_access_to(:join, hash_with_user).via(:post) }
          it { should allow_access_to(:invite, hash) }
          it { should allow_access_to(:invite_userid, hash).redirecting_to(invite_bigbluebutton_room_path(room)) }
          it { should_not allow_access_to(:end, hash) }
          it { should allow_access_to(:join_mobile, hash) }
          it { should allow_access_to(:running, hash) }
          it { should allow_access_to(:join_options, hash) }
          it { should allow_access_to(:fetch_recordings, hash) }
          it { should allow_access_to(:invitation, hash) }
          it { should allow_access_to(:send_invitation, hash).via(:post) }

          context "and has opened the room" do
            before :each do
              meeting = FactoryGirl.create(:bigbluebutton_meeting, :room => room, :running => true,
                                           :creator_id => user.id, :creator_name => user.full_name)
              BigbluebuttonRoom.any_instance.stub(:start_time).and_return(meeting.start_time.utc)
            end
            it { should allow_access_to(:end, hash) }
          end
        end

        context "he is a admin of" do
          before { space.add_member!(user, "Admin") }
          it { should_not allow_access_to(:show, hash) }
          it { should_not allow_access_to(:edit, hash) }
          it { should_not allow_access_to(:update, hash).via(:put) }
          it { should_not allow_access_to(:destroy, hash).via(:delete) }
          it { should allow_access_to(:join, hash_with_user) }
          it { should allow_access_to(:join, hash_with_user).via(:post) }
          it { should allow_access_to(:invite, hash) }
          it { should allow_access_to(:invite_userid, hash).redirecting_to(invite_bigbluebutton_room_path(room)) }
          it { should allow_access_to(:end, hash) }
          it { should allow_access_to(:join_mobile, hash) }
          it { should allow_access_to(:running, hash) }
          it { should allow_access_to(:join_options, hash) }
          it { should allow_access_to(:fetch_recordings, hash) }
          it { should allow_access_to(:invitation, hash) }
          it { should allow_access_to(:send_invitation, hash).via(:post) }
        end

        context "he is not a member of" do
          it { should_not allow_access_to(:show, hash) }
          it { should_not allow_access_to(:edit, hash) }
          it { should_not allow_access_to(:update, hash).via(:put) }
          it { should_not allow_access_to(:destroy, hash).via(:delete) }
          it { should allow_access_to(:join, hash_with_user) }
          it { should allow_access_to(:join, hash_with_user).via(:post) }
          it { should allow_access_to(:invite, hash) }
          it { should allow_access_to(:invite_userid, hash).redirecting_to(invite_bigbluebutton_room_path(room)) }
          it { should_not allow_access_to(:end, hash) }
          it { should allow_access_to(:join_mobile, hash) }
          it { should allow_access_to(:running, hash) }
          it { should_not allow_access_to(:join_options, hash) }
          it { should_not allow_access_to(:fetch_recordings, hash) }
          it { should_not allow_access_to(:invitation, hash) }
          it { should_not allow_access_to(:send_invitation, hash).via(:post) }
        end
      end

    end

    context "for an anonymous user", :user => "anonymous" do
      let(:hash) { { :id => room.to_param } }
      let(:hash_with_user) { hash.merge({ :user => { :name => "User Name", :key => room.attendee_key } }) }

      it { should require_authentication_for(:index) }
      it { should require_authentication_for(:new) }
      it { should require_authentication_for(:create).via(:post) }

      # the permissions are always the same, doesn't matter the type of room, so
      # we have them all in this common method
      shared_examples_for "an anonymous user accessing any webconf room" do
        it { should require_authentication_for(:show, hash) }
        it { should require_authentication_for(:edit, hash) }
        it { should require_authentication_for(:update, hash).via(:put) }
        it { should require_authentication_for(:destroy, hash).via(:delete) }
        it { should allow_access_to(:join, hash_with_user) }
        it { should allow_access_to(:join, hash_with_user).via(:post) }
        it { should allow_access_to(:invite, hash).redirecting_to(join_webconf_path(room)) }
        it { should allow_access_to(:invite_userid, hash) }
        it { should require_authentication_for(:end, hash) }
        it { should allow_access_to(:join_mobile, hash) }
        it { should allow_access_to(:running, hash) }
        it { should require_authentication_for(:join_options, hash) }
        it { should_not allow_access_to(:fetch_recordings, hash) }
        it { should require_authentication_for(:invitation, hash) }
        it { should require_authentication_for(:send_invitation, hash).via(:post) }
      end

      context "in a user room" do
        let(:room) { FactoryGirl.create(:superuser).bigbluebutton_room }
        it_should_behave_like "an anonymous user accessing any webconf room"
      end

      context "in the room of public space" do
        let(:space) { FactoryGirl.create(:space, :public => true) }
        let(:room) { space.bigbluebutton_room }
        it_should_behave_like "an anonymous user accessing any webconf room"
      end

      context "in the room of private space" do
        let(:space) { FactoryGirl.create(:space, :public => false) }
        let(:room) { space.bigbluebutton_room }
        it_should_behave_like "an anonymous user accessing any webconf room"
      end
    end
  end

end
