require "spec_helper"

describe CustomBigbluebuttonServersController do
  include ActionController::AuthenticationTestHelper
  # render_views

  context "authenticates a" do
    render_views false
    let(:server) { Factory.create(:bigbluebutton_server) }

    context "superuser" do
      before(:each) { login_as(Factory.create(:superuser)) }
      it { should allow_access_to(:index) }
      it { should allow_access_to(:new) }
      it { should allow_access_to(:show, :get, { :id => server.to_param }) }
      it { should allow_access_to(:edit, :get, { :id => server.to_param }) }
      it { should allow_access_to(:activity, :get, { :id => server.to_param }) }
      it { should allow_access_to(:create, :post) }
      it { should allow_access_to(:update, :put, { :id => server.to_param }) }
      it { should allow_access_to(:destroy, :delete, { :id => server.to_param }) }
    end

    context "user" do
      before(:each) { login_as(Factory.create(:user)) }
      it { should_not allow_access_to(:index) }
      it { should_not allow_access_to(:new) }
      it { should_not allow_access_to(:show, :get, { :id => server.to_param }) }
      it { should_not allow_access_to(:edit, :get, { :id => server.to_param }) }
      it { should_not allow_access_to(:activity, :get, { :id => server.to_param }) }
      it { should_not allow_access_to(:create, :post) }
      it { should_not allow_access_to(:update, :put, { :id => server.to_param }) }
      it { should_not allow_access_to(:destroy, :delete, { :id => server.to_param }) }
    end

    context "anonymous user" do
      it { should_not allow_access_to(:index).with_response_code(:redirect) }
      it { should_not allow_access_to(:new).with_response_code(:redirect) }
      it { should_not allow_access_to(:show, :get, { :id => server.to_param }).with_response_code(:redirect) }
      it { should_not allow_access_to(:edit, :get, { :id => server.to_param }).with_response_code(:redirect) }
      it { should_not allow_access_to(:activity, :get, { :id => server.to_param }).with_response_code(:redirect) }
      it { should_not allow_access_to(:create, :post).with_response_code(:redirect) }
      it { should_not allow_access_to(:update, :put, { :id => server.to_param }).with_response_code(:redirect) }
      it { should_not allow_access_to(:destroy, :delete, { :id => server.to_param }).with_response_code(:redirect) }
    end

  end

end
