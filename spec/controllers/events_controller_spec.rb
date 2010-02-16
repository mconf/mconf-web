require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe EventsController do
  include ActionController::AuthenticationTestHelper
  
  integrate_views
  
  before do
    @event_public = Factory(:event_public)
  end

  it "should render index" do
    get :index, :space_id => @event_public.space.to_param

    assert_response 200
  end

  it "should render show" do
    get :show, :space_id => @event_public.space.to_param, :id => @event_public.to_param

    assert_response 200
  end
end
 
