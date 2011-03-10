require "spec_helper"

describe Invitation do
  describe "with a role higher than introducer role" do
    before do
      @invitation = Factory(:invitation)
      Factory(:user_performance, :agent => @invitation.introducer,
                                 :stage => @invitation.group)
      @invitation.role = Space.role("Admin")
    end

    it "should not be valid" do
      @invitation.should_not be_valid
      @invitation.should have(1).error_on(:role)
    end
  end
end

