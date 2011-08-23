require "spec_helper"

describe CustomBigbluebuttonRoomsController do
  include ActionController::AuthenticationTestHelper
  render_views

  context "authenticates a" do
    render_views false
    let(:room) { Factory.create(:bigbluebutton_room) }
    let(:hash) { { :server_id => room.server.to_param } }
    let(:hash_with_id) { hash.merge!(:id => room.to_param) }

    context "superuser" do
      before(:each) { login_as(Factory.create(:superuser)) }
      it { should_not deny_access_to(:index, hash) }
      it { should_not deny_access_to(:new, hash) }
      it { should_not deny_access_to(:show, hash_with_id) }
      it { should_not deny_access_to(:edit, hash_with_id) }
      it { should_not deny_access_to(:create, hash).via(:post) }
      it { should_not deny_access_to(:update, hash_with_id).via(:put) }
      it { should_not deny_access_to(:destroy, hash_with_id).via(:delete) }
      it { should_not deny_access_to(:join, hash_with_id) }
      it { should_not deny_access_to(:join, hash_with_id).via(:post) }
      it { should_not deny_access_to(:invite, hash_with_id) }
      it { should_not deny_access_to(:external, hash) }
      it { should_not deny_access_to(:external, hash).via(:post) }
      it { should_not deny_access_to(:end, hash_with_id) }
      it { should_not deny_access_to(:join_mobile, hash_with_id) }
      it { should_not deny_access_to(:running, hash_with_id) }
    end

    context "user" do
      before(:each) { login_as(Factory.create(:user)) }
      it { should deny_access_to(:index, hash) }
      it { should deny_access_to(:new, hash) }
      it { should deny_access_to(:show, hash_with_id) }
      it { should deny_access_to(:edit, hash_with_id) }
      it { should deny_access_to(:create, hash).via(:post) }
      it { should deny_access_to(:update, hash_with_id).via(:put) }
      it { should deny_access_to(:destroy, hash_with_id).via(:delete) }
      it { should_not deny_access_to(:external, hash) }
      it { should_not deny_access_to(:external, hash).via(:post) }
      it { should_not deny_access_to(:join, hash_with_id) }
      it { should_not deny_access_to(:join, hash_with_id).via(:post) }
      it { should_not deny_access_to(:invite, hash_with_id) }
      it { should_not deny_access_to(:end, hash_with_id) }
      it { should_not deny_access_to(:join_mobile, hash_with_id) }
      it { should_not deny_access_to(:running, hash_with_id) }
    end

    context "anonymous user" do
      it { should deny_access_to(:index, hash).using_code(:redirect) }
      it { should deny_access_to(:new, hash).using_code(:redirect) }
      it { should deny_access_to(:show, hash_with_id).using_code(:redirect) }
      it { should deny_access_to(:edit, hash_with_id).using_code(:redirect) }
      it { should deny_access_to(:create, hash).via(:post).using_code(:redirect) }
      it { should deny_access_to(:update, hash_with_id).via(:put).using_code(:redirect) }
      it { should deny_access_to(:destroy, hash_with_id).via(:delete).using_code(:redirect) }
      it { should deny_access_to(:join, hash_with_id).using_code(:redirect) }
      it { should deny_access_to(:end, hash_with_id).using_code(:redirect) }
      it { should deny_access_to(:join_mobile, hash_with_id).using_code(:redirect) }
      it { should_not deny_access_to(:external, hash) }
      it { should_not deny_access_to(:external, hash).via(:post) }
      it { should_not deny_access_to(:join, hash_with_id).via(:post) }
      it { should_not deny_access_to(:invite, hash_with_id) }
      it { should_not deny_access_to(:running, hash_with_id) }
    end

  end

end
