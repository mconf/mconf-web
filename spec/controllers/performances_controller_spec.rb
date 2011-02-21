require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PerformancesController do
  include ActionController::AuthenticationTestHelper
  
  render_views
 
  describe "as Invited" do
    before do
      @performance = Factory(:invited_performance)
      login_as(@performance.agent)
    end

    it "should destroy his own performance" do
      delete :destroy, :id => @performance.id

      assert_nil Performance.find_by_id(@performance.id)
    end
  end
end
