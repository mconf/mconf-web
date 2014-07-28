# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe FrontpageController do

  describe "#show" do

    context "after a user successfully login" do
      before do
        login_as(FactoryGirl.create(:user))
        get :show
      end

      it { response.should redirect_to my_home_path }
    end
  end

end
