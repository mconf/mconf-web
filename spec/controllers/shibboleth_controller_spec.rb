require "spec_helper"

describe ShibbolethController do

  describe "#associate" do
    it "creates a new user account if params[:new_account] is set"
    it "works if the user's name has non UTF-8 characters"
    it "doesn't change the shibboleth data in the session when creating a new user"
  end

end
