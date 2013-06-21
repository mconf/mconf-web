require "spec_helper"

describe CustomBigbluebuttonRoomsController do
  include ActionController::AuthenticationTestHelper
  render_views

  context "checks access permissions for a(n)" do
    render_views false
    let(:room) { Factory.create(:bigbluebutton_room) }
    let(:hash_with_server) { { :server_id => room.server.id } }
    let(:hash) { hash_with_server.merge!(:id => room.to_param) }

    context "superuser" do
      before(:each) { login_as(Factory.create(:superuser)) }
      it { should_not deny_access_to(:index) }
      it { should_not deny_access_to(:new) }
      it { should_not deny_access_to(:show, hash) }
      it { should_not deny_access_to(:edit, hash) }
      it { should_not deny_access_to(:create).via(:post) }
      it { should_not deny_access_to(:update, hash).via(:put) }
      it { should_not deny_access_to(:destroy, hash).via(:delete) }
      it { should_not deny_access_to(:join, hash) }
      it { should_not deny_access_to(:join, hash).via(:post) }
      it { should_not deny_access_to(:invite, hash) }
      it { should_not deny_access_to(:invite_userid, hash) }
      it { should_not deny_access_to(:external, hash_with_server) }
      it { should_not deny_access_to(:external, hash_with_server).via(:post) }
      it { should_not deny_access_to(:end, hash) }
      it { should_not deny_access_to(:join_mobile, hash) }
      it { should_not deny_access_to(:running, hash) }
    end

    context "user" do
      before(:each) { login_as(Factory.create(:user)) }
      it { should deny_access_to(:index) }
      it { should deny_access_to(:new) }
      it { should deny_access_to(:show, hash) }
      it { should deny_access_to(:edit, hash) }
      it { should deny_access_to(:create, hash_with_server).via(:post) }
      it { should deny_access_to(:update, hash).via(:put) }
      it { should deny_access_to(:destroy, hash).via(:delete) }
      it { should_not deny_access_to(:external, hash_with_server) }
      it { should_not deny_access_to(:external, hash_with_server).via(:post) }
      it { should_not deny_access_to(:join, hash) }
      it { should_not deny_access_to(:join, hash).via(:post) }
      it { should_not deny_access_to(:invite, hash) }
      it { should_not deny_access_to(:invite_userid, hash) }
      it { should_not deny_access_to(:end, hash) }
      it { should_not deny_access_to(:join_mobile, hash) }
      it { should_not deny_access_to(:running, hash) }
    end

    context "anonymous user" do
      it { should deny_access_to(:index).using_code(:redirect) }
      it { should deny_access_to(:new).using_code(:redirect) }
      it { should deny_access_to(:show, hash).using_code(:redirect) }
      it { should deny_access_to(:edit, hash).using_code(:redirect) }
      it { should deny_access_to(:create, hash_with_server).via(:post).using_code(:redirect) }
      it { should deny_access_to(:update, hash).via(:put).using_code(:redirect) }
      it { should deny_access_to(:destroy, hash).via(:delete).using_code(:redirect) }
      it { should deny_access_to(:join, hash).using_code(:redirect) }
      it { should deny_access_to(:end, hash).using_code(:redirect) }
      it { should deny_access_to(:join_mobile, hash).using_code(:redirect) }
      it { should deny_access_to(:invite, hash).using_code(:redirect) }
      it { should_not deny_access_to(:external, hash_with_server) }
      it { should_not deny_access_to(:external, hash_with_server).via(:post) }
      it { should_not deny_access_to(:join, hash).via(:post) }
      it { should_not deny_access_to(:invite_userid, hash) }
      it { should_not deny_access_to(:running, hash) }
    end
  end

  context "#invite_userid" do
    let(:room) { Factory.create(:bigbluebutton_room, :private => false) }
    let(:hash) { { :server_id => room.server.to_param, :id => room.to_param } }

    context do
      before(:each) { get :invite_userid, hash }
      it { should render_with_layout("application_without_sidebar") }
    end

    context "redirects to #invite" do
      let(:user) { Factory(:user) }

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

  context "#invite" do
    let(:room) { Factory.create(:bigbluebutton_room) }
    let(:hash) { { :server_id => room.server.to_param, :id => room.to_param } }

    context do
      let(:hash) { { :server_id => room.server.to_param, :id => room.to_param } }
      before { controller.should_receive(:bigbluebutton_role) { :password } }
      before(:each) {
        login_as(Factory.create(:superuser))
        get :invite, hash
      }
      it { should render_with_layout("application_without_sidebar") }
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

  context "#auth" do
    # renders a view when unauthorized
    let(:user) { Factory.create(:user) }
    let(:room) { Factory.create(:bigbluebutton_room, :private => false) }
    before {
      request.env["HTTP_REFERER"] = "/any"
      controller.should_receive(:bigbluebutton_role) { :password }
    }
    before(:each) {
      login_as(user)
      post :auth, :id => room.to_param, :user => { }
    }
    it { should render_template(:invite) }
    it { should render_with_layout("application_without_sidebar") }
  end

  context "#index" do
    before(:each) { login_as(Factory.create(:superuser)) }
    before(:each) { get :index }
    it { should render_template(:index) }
    it { should render_with_layout("application") }
  end

  describe "#show" do
    let(:room) { Factory.create(:bigbluebutton_room) }
    before(:each) { login_as(Factory.create(:superuser)) }
    before(:each) { get :show, :id => room.to_param }
    it { should render_template(:show) }
    it { should render_with_layout("application") }
  end

  describe "#new" do
    before(:each) { login_as(Factory.create(:superuser)) }
    before(:each) { get :new }
    it { should render_template(:new) }
    it { should render_with_layout("application") }
  end

  describe "#edit" do
    let(:room) { Factory.create(:bigbluebutton_room) }
    before(:each) { login_as(Factory.create(:superuser)) }
    before(:each) { get :edit, :id => room.to_param }
    it { should render_template(:edit) }
    it { should render_with_layout("application") }
  end

  describe "#join_mobile" do
    let(:room) { Factory.create(:bigbluebutton_room) }
    before(:each) { login_as(Factory.create(:superuser)) }
    before(:each) { get :join_mobile, :id => room.to_param }
    it { should render_template(:join_mobile) }
    it { should_not render_with_layout() }
  end

  describe "#create" do
    # renders a view on error on save
    let(:new_room) { Factory.build(:bigbluebutton_room) }
    before(:each) { login_as(Factory.create(:superuser)) }
    before :each do
      new_room.name = nil # invalid
      post :create, :bigbluebutton_room => new_room.attributes
    end
    it { should render_template(:new) }
    it { should render_with_layout("application") }
  end

  describe "#update" do
    # renders a view on error on save
    let(:room) { Factory.create(:bigbluebutton_room) }
    let(:new_room) { Factory.build(:bigbluebutton_room) }
    before(:each) { login_as(Factory.create(:superuser)) }
    before(:each) {
      new_room.name = nil # invalid
      put :update, :id => room.to_param, :bigbluebutton_room => new_room.attributes
    }
    it { should render_template(:edit) }
    it { should render_with_layout("application") }
  end

  describe "#running" do
    # renders json only
    let(:room) { Factory.create(:bigbluebutton_room) }
    before(:each) { login_as(Factory.create(:superuser)) }
    before(:each) { get :running, :id => room.to_param }
    it { should respond_with(:success) }
    it { should_not render_with_layout() }
  end

  describe "#external" do
    let(:server) { Factory.create(:bigbluebutton_server) }
    before(:each) { login_as(Factory.create(:superuser)) }
    before(:each) { get :external, :meeting => "my-meeting-id", :server_id => server.id }
    it { should render_template(:external) }
    it { should render_with_layout("application") }
  end

  describe "#external_auth" do
    pending "render with layout application"
  end

  # TODO: this view is not in the application yet, only in the gem
  # describe "#recordings" do
  #   let(:room) { Factory.create(:bigbluebutton_room) }
  #   before(:each) { login_as(Factory.create(:superuser)) }
  #   before(:each) { get :recordings, :id => room.to_param }
  #   it { should render_template(:recordings) }
  #   it { should render_with_layout("application") }
  # end

end
