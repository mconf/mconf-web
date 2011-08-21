require "spec_helper"

describe CustomBigbluebuttonRoomsController do
  include ActionController::AuthenticationTestHelper
  render_views

  context "authenticates a" do
    render_views false
    let(:room) { Factory.create(:bigbluebutton_room) }
    let(:hash) { { :server_id => room.server.to_param } }

    context "superuser" do
      before(:each) { login_as(Factory.create(:superuser)) }
      it { should allow_access_to(:index, :get, hash) }
      it { should allow_access_to(:new, :get, hash) }
      it { should allow_access_to(:show, :get, hash.merge!(:id => room.to_param)) }
      it { should allow_access_to(:edit, :get, hash.merge!(:id => room.to_param)) }
      it { should allow_access_to(:create, :post, hash) }
      it { should allow_access_to(:update, :put, hash.merge!(:id => room.to_param)) }
      it { should allow_access_to(:destroy, :delete, hash.merge!(:id => room.to_param)) }
      it { should allow_access_to(:join, :get, hash.merge!(:id => room.to_param)) }
      it { should allow_access_to(:join, :post, hash.merge!(:id => room.to_param)) }
      it { should allow_access_to(:invite, :get, hash.merge!(:id => room.to_param)) }
      it { should allow_access_to(:external, :get, hash) }
      it { should allow_access_to(:external, :post, hash) }
      it { should allow_access_to(:end, :get, hash.merge!(:id => room.to_param)) }
      it { should allow_access_to(:join_mobile, :get, hash.merge!(:id => room.to_param)) }
      it { should allow_access_to(:running, :get, hash.merge!(:id => room.to_param)) }
    end

    context "user" do
      before(:each) { login_as(Factory.create(:user)) }
      it { should_not allow_access_to(:index, :get, hash) }
      it { should_not allow_access_to(:new, :get, hash) }
      it { should_not allow_access_to(:show, :get, hash.merge!(:id => room.to_param)) }
      it { should_not allow_access_to(:edit, :get, hash.merge!(:id => room.to_param)) }
      it { should_not allow_access_to(:create, :post, hash) }
      it { should_not allow_access_to(:update, :put, hash.merge!(:id => room.to_param)) }
      it { should_not allow_access_to(:destroy, :delete, hash.merge!(:id => room.to_param)) }
      it { should allow_access_to(:external, :get, hash) }
      it { should allow_access_to(:external, :post, hash) }
      it { should allow_access_to(:join, :get, hash.merge!(:id => room.to_param)) }
      it { should allow_access_to(:join, :post, hash.merge!(:id => room.to_param)) }
      it { should allow_access_to(:invite, :get, hash.merge!(:id => room.to_param)) }
      it { should allow_access_to(:end, :get, hash.merge!(:id => room.to_param)) }
      it { should allow_access_to(:join_mobile, :get, hash.merge!(:id => room.to_param)) }
      it { should allow_access_to(:running, :get, hash.merge!(:id => room.to_param)) }
    end

    context "anonymous user" do
      it { should_not allow_access_to(:index, :get, hash).with_response_code(:redirect) }
      it { should_not allow_access_to(:new, :get, hash).with_response_code(:redirect) }
      it { should_not allow_access_to(:show, :get, hash.merge!(:id => room.to_param)).with_response_code(:redirect) }
      it { should_not allow_access_to(:edit, :get, hash.merge!(:id => room.to_param)).with_response_code(:redirect) }
      it { should_not allow_access_to(:create, :post, hash).with_response_code(:redirect) }
      it { should_not allow_access_to(:update, :put, hash.merge!(:id => room.to_param)).with_response_code(:redirect) }
      it { should_not allow_access_to(:destroy, :delete, hash.merge!(:id => room.to_param)).with_response_code(:redirect) }
      it { should_not allow_access_to(:join, :get, hash.merge!(:id => room.to_param)).with_response_code(:redirect) }
      it { should_not allow_access_to(:end, :get, hash.merge!(:id => room.to_param)).with_response_code(:redirect) }
      it { should_not allow_access_to(:join_mobile, :get, hash.merge!(:id => room.to_param)).with_response_code(:redirect) }
      it { should allow_access_to(:external, :get, hash) }
      it { should allow_access_to(:external, :post, hash) }
      it { should allow_access_to(:join, :post, hash.merge!(:id => room.to_param)) }
      it { should allow_access_to(:invite, :get, hash.merge!(:id => room.to_param)) }
      it { should allow_access_to(:running, :get, hash.merge!(:id => room.to_param)) }
    end

  end

end
