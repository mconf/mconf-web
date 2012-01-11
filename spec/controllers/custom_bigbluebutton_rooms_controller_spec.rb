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
      it { should_not deny_access_to(:external, hash_with_server) }
      it { should_not deny_access_to(:external, hash_with_server).via(:post) }
      it { should_not deny_access_to(:join, hash).via(:post) }
      it { should_not deny_access_to(:invite, hash) }
      it { should_not deny_access_to(:running, hash) }
    end

  end

end
