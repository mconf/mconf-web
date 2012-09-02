# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

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

