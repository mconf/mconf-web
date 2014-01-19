require "spec_helper"

describe ShibbolethController do

  describe "#associate" do
    it "creates a new user account if params[:new_account] is set"
    it "works if the user's name has non UTF-8 characters"
    it "doesn't change the shibboleth data in the session when creating a new user"
  end

  describe "#login" do

    # to make sure we're not forgetting a call to #test_data (happened before)
    it "doesn't call #test_data" do
      Site.current.update_attributes(:shib_enabled => true)
      controller.should_not_receive(:test_data)
      get :login
      request.env.each { |key, value| key.should_not match(/shib-/i) }
    end
  end

end
