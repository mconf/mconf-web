# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe CustomBigbluebuttonRoomsController do
  render_views

  describe "abilities" do
    render_views(false)

    context "for a superuser", :user => "superuser" do
      let(:user) { FactoryGirl.create(:superuser) }
      let(:hash_with_server) { { :server_id => room.server.id } }
      let(:hash) { hash_with_server.merge!(:id => room.to_param) }
      before(:each) { login_as(user) }

      it { should allow_access_to(:index) }
      it { should allow_access_to(:new) }
      it { should allow_access_to(:create).via(:post) }

      # the permissions are always the same, doesn't matter the type of room, so
      # we have them all in this common method
      shared_examples_for "a superuser accessing any webconf room" do
        it { should allow_access_to(:show, hash) }
        it { should allow_access_to(:edit, hash) }
        it { should allow_access_to(:update, hash).via(:put) }
        it { should allow_access_to(:destroy, hash).via(:delete) }
        it { should allow_access_to(:join, hash) }
        it { should allow_access_to(:auth, hash).via(:post) }
        it { should allow_access_to(:invite, hash) }
        it { should allow_access_to(:invite_userid, hash).redirecting_to(invite_bigbluebutton_room_path(room)) }
        it { should allow_access_to(:external, hash_with_server) }
        it { should allow_access_to(:external_auth, hash_with_server).via(:post) }
        it { should allow_access_to(:end, hash) }
        it { should allow_access_to(:join_mobile, hash) }
        it { should allow_access_to(:running, hash) }
      end

      context "in his room" do
        let(:room) { user.bigbluebutton_room }
        it_should_behave_like "a superuser accessing any webconf room"
      end

      context "in another user's room" do
        let(:room) { FactoryGirl.create(:superuser).bigbluebutton_room }
        it_should_behave_like "a superuser accessing any webconf room"
      end

      context "in the room of public space" do
        let(:space) { FactoryGirl.create(:space, :public => true) }
        let(:room) { space.bigbluebutton_room }

        context "he is a member of" do
          before { space.add_member!(user) }
          it_should_behave_like "a superuser accessing any webconf room"
        end

        context "he is not a member of" do
          it_should_behave_like "a superuser accessing any webconf room"
        end
      end

      context "in the room of private space" do
        let(:space) { FactoryGirl.create(:space, :public => false) }
        let(:room) { space.bigbluebutton_room }

        context "he is a member of" do
          before { space.add_member!(user) }
          it_should_behave_like "a superuser accessing any webconf room"
        end

        context "he is not a member of" do
          it_should_behave_like "a superuser accessing any webconf room"
        end
      end
    end

    context "for a normal user", :user => "normal" do
      let(:user) { FactoryGirl.create(:user) }
      let(:hash_with_server) { { :server_id => room.server.id } }
      let(:hash) { hash_with_server.merge!(:id => room.to_param) }
      before(:each) { login_as(user) }

      it { should_not allow_access_to(:index) }
      it { should_not allow_access_to(:new) }
      it { should_not allow_access_to(:create).via(:post) }

      context "in his room" do
        let(:room) { user.bigbluebutton_room }
        it { should_not allow_access_to(:show, hash) }
        it { should_not allow_access_to(:edit, hash) }
        it { should_not allow_access_to(:update, hash).via(:put) }
        it { should_not allow_access_to(:destroy, hash).via(:delete) }
        it { should allow_access_to(:join, hash) }
        it { should allow_access_to(:auth, hash).via(:post) }
        it { should allow_access_to(:invite, hash) }
        it { should allow_access_to(:invite_userid, hash).redirecting_to(invite_bigbluebutton_room_path(room)) }
        it { should allow_access_to(:external, hash_with_server) }
        it { should allow_access_to(:external_auth, hash_with_server).via(:post) }
        it { should allow_access_to(:end, hash) }
        it { should allow_access_to(:join_mobile, hash) }
        it { should allow_access_to(:running, hash) }
      end

      context "in another user's room" do
        let(:room) { FactoryGirl.create(:superuser).bigbluebutton_room }
        it { should_not allow_access_to(:show, hash) }
        it { should_not allow_access_to(:edit, hash) }
        it { should_not allow_access_to(:update, hash).via(:put) }
        it { should_not allow_access_to(:destroy, hash).via(:delete) }
        it { should allow_access_to(:external, hash_with_server) }
        it { should allow_access_to(:external_auth, hash_with_server).via(:post) }
        it { should allow_access_to(:join, hash) }
        it { should allow_access_to(:auth, hash).via(:post) }
        it { should allow_access_to(:invite, hash) }
        it { should allow_access_to(:invite_userid, hash).redirecting_to(invite_bigbluebutton_room_path(room)) }
        it { should_not allow_access_to(:end, hash) }
        it { should allow_access_to(:join_mobile, hash) }
        it { should allow_access_to(:running, hash) }
      end

      context "in the room of public space" do
        let(:space) { FactoryGirl.create(:space, :public => true) }
        let(:room) { space.bigbluebutton_room }

        context "he is a member of" do
          before { space.add_member!(user) }
          it { should_not allow_access_to(:show, hash) }
          it { should_not allow_access_to(:edit, hash) }
          it { should_not allow_access_to(:update, hash).via(:put) }
          it { should_not allow_access_to(:destroy, hash).via(:delete) }
          it { should allow_access_to(:external, hash_with_server) }
          it { should allow_access_to(:external_auth, hash_with_server).via(:post) }
          it { should allow_access_to(:join, hash) }
          it { should allow_access_to(:auth, hash).via(:post) }
          it { should allow_access_to(:invite, hash) }
          it { should allow_access_to(:invite_userid, hash).redirecting_to(invite_bigbluebutton_room_path(room)) }
          it { should allow_access_to(:end, hash) }
          it { should allow_access_to(:join_mobile, hash) }
          it { should allow_access_to(:running, hash) }
        end

        context "he is not a member of" do
          it { should_not allow_access_to(:show, hash) }
          it { should_not allow_access_to(:edit, hash) }
          it { should_not allow_access_to(:update, hash).via(:put) }
          it { should_not allow_access_to(:destroy, hash).via(:delete) }
          it { should allow_access_to(:external, hash_with_server) }
          it { should allow_access_to(:external_auth, hash_with_server).via(:post) }
          it { should allow_access_to(:join, hash) }
          it { should allow_access_to(:auth, hash).via(:post) }
          it { should allow_access_to(:invite, hash) }
          it { should allow_access_to(:invite_userid, hash).redirecting_to(invite_bigbluebutton_room_path(room)) }
          it { should_not allow_access_to(:end, hash) }
          it { should allow_access_to(:join_mobile, hash) }
          it { should allow_access_to(:running, hash) }
        end
      end

      context "in the room of private space" do
        let(:space) { FactoryGirl.create(:space, :public => false) }
        let(:room) { space.bigbluebutton_room }

        context "he is a member of" do
          before { space.add_member!(user) }
          it { should_not allow_access_to(:show, hash) }
          it { should_not allow_access_to(:edit, hash) }
          it { should_not allow_access_to(:update, hash).via(:put) }
          it { should_not allow_access_to(:destroy, hash).via(:delete) }
          it { should allow_access_to(:external, hash_with_server) }
          it { should allow_access_to(:external_auth, hash_with_server).via(:post) }
          it { should allow_access_to(:join, hash) }
          it { should allow_access_to(:auth, hash).via(:post) }
          it { should allow_access_to(:invite, hash) }
          it { should allow_access_to(:invite_userid, hash).redirecting_to(invite_bigbluebutton_room_path(room)) }
          it { should allow_access_to(:end, hash) }
          it { should allow_access_to(:join_mobile, hash) }
          it { should allow_access_to(:running, hash) }
        end

        context "he is not a member of" do
          it { should_not allow_access_to(:show, hash) }
          it { should_not allow_access_to(:edit, hash) }
          it { should_not allow_access_to(:update, hash).via(:put) }
          it { should_not allow_access_to(:destroy, hash).via(:delete) }
          it { should allow_access_to(:external, hash_with_server) }
          it { should allow_access_to(:external_auth, hash_with_server).via(:post) }
          it { should allow_access_to(:join, hash) }
          it { should allow_access_to(:auth, hash).via(:post) }
          it { should allow_access_to(:invite, hash) }
          it { should allow_access_to(:invite_userid, hash).redirecting_to(invite_bigbluebutton_room_path(room)) }
          it { should_not allow_access_to(:end, hash) }
          it { should allow_access_to(:join_mobile, hash) }
          it { should allow_access_to(:running, hash) }
        end
      end

    end

    context "for an anonymous user", :user => "anonymous" do
      let(:hash_with_server) { { :server_id => room.server.id } }
      let(:hash) { hash_with_server.merge!(:id => room.to_param) }

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
        it { should require_authentication_for(:join, hash) }
        it { should allow_access_to(:auth, hash).via(:post) }
        it { should allow_access_to(:invite, hash).redirecting_to(join_webconf_path(room)) }
        it { should allow_access_to(:invite_userid, hash) }
        it { should require_authentication_for(:external, hash_with_server) }
        it { should require_authentication_for(:external_auth, hash_with_server).via(:post) }
        it { should require_authentication_for(:end, hash) }
        it { should require_authentication_for(:join_mobile, hash) }
        it { should allow_access_to(:running, hash) }
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

  describe "#invite_userid" do
    context "template and layout" do
      let(:room) { FactoryGirl.create(:bigbluebutton_room, :private => false) }
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
  end

  describe "#invite" do
    context "template and layout" do
      let(:room) { FactoryGirl.create(:bigbluebutton_room) }
      let(:hash) { { :server_id => room.server.to_param, :id => room.to_param } }

      context "template" do
        let(:hash) { { :server_id => room.server.to_param, :id => room.to_param } }
        before { controller.should_receive(:bigbluebutton_role) { :password } }
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
  end

  describe "#auth" do
    context "template and layout" do
      # renders a view only when unauthorized
      let(:user) { FactoryGirl.create(:user) }
      let(:room) { FactoryGirl.create(:bigbluebutton_room, :private => false) }
      before {
        request.env["HTTP_REFERER"] = "/any"
        controller.should_receive(:bigbluebutton_role) { :password }
      }
      before(:each) {
        login_as(user)
        post :auth, :id => room.to_param, :user => { }
      }
      it { should render_template(:invite) }
      it { should render_with_layout("no_sidebar") }
    end
  end

  describe "#index" do
    context "template and layout" do
      before(:each) { login_as(FactoryGirl.create(:superuser)) }
      before(:each) { get :index }
      it { should render_template(:index) }
      it { should render_with_layout("application") }
    end
  end

  describe "#show" do
    context "template and layout" do
      let(:room) { FactoryGirl.create(:bigbluebutton_room) }
      before(:each) { login_as(FactoryGirl.create(:superuser)) }
      before(:each) { get :show, :id => room.to_param }
      it { should render_template(:show) }
      it { should render_with_layout("application") }
    end
  end

  describe "#new" do
    context "template and layout" do
      before(:each) { login_as(FactoryGirl.create(:superuser)) }
      before(:each) { get :new }
      it { should render_template(:new) }
      it { should render_with_layout("application") }
    end
  end

  describe "#edit" do
    context "template and layout" do
      let(:room) { FactoryGirl.create(:bigbluebutton_room) }
      before(:each) { login_as(FactoryGirl.create(:superuser)) }
      before(:each) { get :edit, :id => room.to_param }
      it { should render_template(:edit) }
      it { should render_with_layout("application") }
    end
  end

  describe "#join_mobile" do
    let(:room) { FactoryGirl.create(:bigbluebutton_room) }
    before(:each) { login_as(FactoryGirl.create(:superuser)) }

    context "template and layout for html requests" do
      before(:each) { get :join_mobile, :id => room.to_param }
      it { should render_template(:join_mobile) }
      it { should render_with_layout("application") }
    end

    context "template and layout for xhr requests" do
      before(:each) { xhr :get, :join_mobile, :id => room.to_param }
      it { should render_template(:join_mobile) }
      it { should_not render_with_layout() }
    end
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

    # TODO: we need rspec 2.14 for the tests below
    #
    # # This is an adapted copy of the same test done for this controller
    # # action in BigbluebuttonRails
    # context "params handling" do
    #   let(:attrs) { FactoryGirl.attributes_for(:bigbluebutton_room) }
    #   let(:params) { { :bigbluebutton_room => attrs } }

    #   context "for a superuser" do
    #     let(:allowed_params) {
    #       [ :name, :server_id, :meetingid, :attendee_password, :moderator_password, :welcome_msg,
    #         :private, :logout_url, :dial_number, :voice_bridge, :max_participants, :owner_id,
    #         :owner_type, :external, :param, :record, :duration,
    #         :metadata_attributes => [ :id, :name, :content, :_destroy, :owner_id ] ]
    #     }
    #     it {
    #       # we just check that the rails method 'permit' is being called on the hash with the
    #       # correct parameters
    #       BigbluebuttonRoom.stub(:find_by_param).and_return(@room)
    #       @room.stub(:update_attributes).and_return(true)
    #       attrs.stub(:permit).and_return(attrs)
    #       controller.stub(:params).and_return(params)

    #       put :update, :id => room.to_param, :bigbluebutton_room => attrs
    #       attrs.should have_received(:permit).with(*allowed_params)
    #     }
    #   end

    #   context "for a normal user" do
    #     let(:allowed_params) {
    #       [ :name ]
    #     }
    #     it {
    #       # we just check that the rails method 'permit' is being called on the hash with the
    #       # correct parameters
    #       BigbluebuttonRoom.stub(:find_by_param).and_return(@room)
    #       @room.stub(:update_attributes).and_return(true)
    #       attrs.stub(:permit).and_return(attrs)
    #       controller.stub(:params).and_return(params)

    #       put :update, :id => room.to_param, :bigbluebutton_room => attrs
    #       attrs.should have_received(:permit).with(*allowed_params)
    #     }
    #   end
    # end
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
  end

  describe "#external" do
    context "template and layout" do
      let(:server) { FactoryGirl.create(:bigbluebutton_server) }
      before(:each) { login_as(FactoryGirl.create(:superuser)) }
      before(:each) { get :external, :meeting => "my-meeting-id", :server_id => server.id }
      it { should render_template(:external) }
      it { should render_with_layout("application") }
    end
  end

  describe "#external_auth" do
    context "template and layout" do
      pending "render with layout application"
    end
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

end
