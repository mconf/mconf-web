require "spec_helper"

describe CustomBigbluebuttonServersController do
  include ActionController::AuthenticationTestHelper
  render_views

  before(:each) do
    @superuser = Factory(:superuser)
    @user = Factory(:user)
  end
  
  describe 'a Superadmin' do
    before(:each) do
      login_as(@superuser)
    end

    it "should show servers" do
      get :index
      
      response.should render_template("index")
    end
  end
  
  describe 'a User' do
    before(:each) do
      login_as(@user)
    end

    it "shouldn't show servers" do
      get :index
      
      response.should_not render_template("index")
    end
  end
  
end
