require "spec_helper"

describe ShibbolethController do

  describe "#associate" do
    it "creates a new user account if params[:new_account] is set"
    it "works if the user's name has non UTF-8 characters"
  end

end
