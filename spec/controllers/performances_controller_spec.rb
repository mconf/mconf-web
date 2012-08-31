# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe PerformancesController do
  include ActionController::AuthenticationTestHelper

  render_views

  describe "as Invited" do
    before do
      @performance = Factory(:invited_performance)
      login_as(@performance.agent)
      request.env["HTTP_REFERER"] = "/"
    end

    it "should destroy his own performance" do
      delete :destroy, :id => @performance.id

      assert_nil Performance.find_by_id(@performance.id)
    end
  end
end
